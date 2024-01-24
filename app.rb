require "sinatra"
require "sqlite3"
require "bcrypt"

get("/") do
    slim(:login)
end

post("/user/login") do
    p params
    redirect("/")
end

post("/user/create") do
    p params
    redirect("/")
end