require_relative "all_of.rb"

def login(username)
    id = getDataBase().execute("SELECT id FROM user WHERE username = (?)", username).first["id"]
    session[:id] = id
    redirect("/questions")
end

before(all_of("/user/login", "/user/create")) do
    session[:login_error] = nil
end

post("/user/login") do
    username = params[:username]
    password = params[:password]

    db = getDataBase()
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
    if (params[:password] != params[:password_confirm])
        p "passwords do not match"
        session[:login_error] = "passwords do not match"
        redirect("/")
    end

    username = params[:username]

    if (getDataBase().execute("SELECT * FROM user WHERE username = (?)", username).length > 0)
        p "username taken"
        session[:login_error] = "username taken"
        redirect("/")
    end

    pwd_digest = BCrypt::Password.create(params[:password])
    getDataBase().execute("INSERT INTO user (username, pwd_digest) VALUES (?, ?)", username, pwd_digest)

    login(username)
end