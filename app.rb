require "sinatra"
require "sqlite3"
require "bcrypt"
require_relative "code/user_posts.rb"
require_relative "code/questions_posts.rb"
require_relative "code/answers_posts.rb"

enable(:sessions)

def getDataBase()
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    return db
end

before() do
    if (session[:id] == nil)
        if (request.request_method == "POST" &&
            request.path_info != "/user/login" &&
            request.path_info != "/user/create")
            redirect("/")
        elsif (request.request_method == "GET" &&
               request.path_info != "/")
            redirect("/")
        end
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

get("/questions/:id") do
    id = params[:id]
    db = getDataBase()
    question = db.execute("SELECT * FROM question WHERE id = (?)", id).first
    
    answers = db.execute("SELECT * FROM answer WHERE question_id = (?)", id)
    answers.each do |a|
        a["owner"] = db.execute("SELECT username FROM user WHERE id = (?)", a["user_id"]).first["username"]
    end

    slim(:"questions/show", locals:{
        question:question,
        answers:answers
    })
end