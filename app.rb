require "sinatra"
require "sqlite3"
require "bcrypt"
require_relative "code/user_routes.rb"
require_relative "code/question_routes.rb"

enable(:sessions)

def getDataBase()
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    return db
end

before() do
    if (request.request_method == "GET" && 
        request.path_info != "/" && 
        session[:id] == nil)
        redirect("/")
    end
end

get("/") do
    slim(:login, locals:{login_error: session[:login_error]})
end

get("/questions") do
    db = getDataBase()
    questions = db.execute("SELECT * FROM question")
    questions.each do |q|
        q["owner"] = db.execute("SELECT username FROM user WHERE id = (?)", q["user_id"]).first["username"]
    end
    slim(:"questions/index", locals:{questions:questions})
end