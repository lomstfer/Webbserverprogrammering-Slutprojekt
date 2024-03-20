require_relative "all_of.rb"

def login(username)
    id = get_data_base().execute("SELECT id FROM user WHERE username = (?)", username).first["id"]
    session[:id] = id
    redirect("/questions")
end

before(all_of("/user/login", "/user/create")) do
    session[:login_error] = nil
    
    if session[:login_create_timestamp] != nil
        d = Time.now.to_f*1000 - session[:login_create_timestamp]
        if d < $LOGIN_CREATE_ACCOUNT_COOLDOWN
            session[:login_error] = "try again in #{$LOGIN_CREATE_ACCOUNT_COOLDOWN - d} milliseconds"
            redirect("/")
        end
    end

    session[:login_create_timestamp] = Time.now.to_f*1000
end

post("/user/login") do
    username = params[:username]
    password = params[:password]

    if (username.length > $USERNAME_MAX_LENGTH)
        session[:login_error] = "wrong username"
        redirect("/")
    end

    if (password.length > $PASSWORD_MAX_LENGTH)
        session[:login_error] = "wrong password"
        redirect("/")
    end

    db = get_data_base()
    users = db.execute("SELECT * FROM user WHERE username = (?)", username)
    if (users.length > 0)
        user = users.first
        pwd_digest = user["pwd_digest"]
        if (BCrypt::Password.new(pwd_digest) != password)
            p "wrong password"
            session[:login_error] = "wrong password"
            redirect("/")
        end
        login(user["username"])
    end

    p "username did not exist"
    session[:login_error] = "user not found"
    redirect("/")
end

post("/user/create") do
    errors = []

    if (params[:password].length > $PASSWORD_MAX_LENGTH)
        errors.push("password too long")
    end

    if (params[:password] != params[:password_confirm])
        errors.push("passwords do not match")
    end
    
    username = params[:username]
    if (get_data_base().execute("SELECT * FROM user WHERE username = (?)", username).length > 0)
        errors.push("username taken")
    end
    
    if (username.length > $USERNAME_MAX_LENGTH)
        errors.push("username too long")
    end

    if (params[:password].length < $PASSWORD_MIN_LENGTH)
        errors.push("password too short")
    end

    if (errors.length > 0)
        session[:login_error] = ""
        errors.each_with_index do |e, i|
            session[:login_error] += e
            if (errors.length - 1 - i > 0)
                session[:login_error] += ", "
            end
        end
        redirect("/")
    end

    pwd_digest = BCrypt::Password.create(params[:password])
    get_data_base().execute("INSERT INTO user (username, pwd_digest) VALUES (?, ?)", username, pwd_digest)

    login(username)
end