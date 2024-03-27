require_relative "all_of.rb"

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
    try_login(params[:username], params[:password])
end

post("/user/create") do
    try_create_account(params[:username], params[:password], params[:password_confirm])
end