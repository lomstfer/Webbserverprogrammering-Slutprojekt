require "sinatra"
require "sqlite3"
require "bcrypt"
require_relative "code/constants.rb"
require_relative "code/user_posts.rb"
require_relative "code/questions_posts.rb"
require_relative "code/answers_posts.rb"
require_relative "code/admin_posts.rb"
require_relative "code/misc_posts.rb"

enable(:sessions)

def get_data_base()
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    return db
end

before() do
    except_routes = ["/login_as_guest"]
    if except_routes.include?(request.path_info) || session[:is_guest]
        return
    end

    if (session[:id] == nil)
        if (request.request_method == "POST" &&
            request.path_info != "/user/login" &&
            request.path_info != "/user/create")
            redirect("/")
        elsif (request.request_method == "GET" &&
               request.path_info != "/")
            redirect("/")
        end
        return
    end

    admin = get_data_base().execute("SELECT is_admin FROM user WHERE id = (?)", session[:id]).first["is_admin"]
    session[:is_admin] = admin == 1
end

before("/admin/*") do
    if (!session[:is_admin])
        redirect("/")
    end
end

get("/") do
    login_error = session[:login_error]
    login_timestamp = session[:login_create_timestamp]
    session.clear()
    session[:login_create_timestamp] = login_timestamp
    slim(:login, locals:{login_error: login_error})
end

get("/questions") do
    db = get_data_base()
    questions = db.execute("SELECT * FROM question")
    questions.each do |q|
        q["owner"] = db.execute("SELECT username FROM user WHERE id = (?)", q["user_id"]).first["username"]
        
        tags_on_question = db.execute("
            SELECT name
            FROM tag
            INNER JOIN question_tag_relation ON question_tag_relation.tag_id = tag.id
            WHERE question_id = (?)",
            q["id"])
        q["tags"] = []
        tags_on_question.each do |t|
            q["tags"].push(t["name"])
        end
    end

    if session[:question_sort_by] == nil
        session[:question_sort_by] = "points_descending"
    end
    if session[:question_sort_by] != nil
        if session[:question_sort_by] == "points_descending"
            questions.sort_by!{|q| -q["points"]}
        elsif session[:question_sort_by] == "points_ascending"
            questions.sort_by!{|q| q["points"]}
        end
    end

    slim(:"questions/index", locals:{
        questions:questions, 
        is_admin:session[:is_admin], 
        is_guest:session[:is_guest],
        question_sort_by:session[:question_sort_by]
    })
end

get("/questions/new") do
    db = get_data_base()
    tags = db.execute("SELECT * FROM tag")
    slim(:"questions/new", locals:{tags:tags})
end

get("/questions/:id") do
    id = params[:id]
    db = get_data_base()
    question = db.execute("SELECT * FROM question WHERE id = (?)", id).first
    owner = db.execute("SELECT username FROM user WHERE id = (?)", question["user_id"]).first["username"]
    question["owner"] = owner
    
    tags_on_question = db.execute("
        SELECT name
        FROM tag
        INNER JOIN question_tag_relation ON question_tag_relation.tag_id = tag.id
        WHERE question_id = (?)",
        question["id"])
    question["tags"] = []
    tags_on_question.each do |t|
        question["tags"].push(t["name"])
    end

    answers = db.execute("SELECT * FROM answer WHERE question_id = (?)", id)
    answers.each do |a|
        a["owner"] = db.execute("SELECT username FROM user WHERE id = (?)", a["user_id"]).first["username"]
    end

    slim(:"questions/show", locals:{
        question:question,
        answers:answers,
        is_admin:session[:is_admin],
        is_guest:session[:is_guest]
    })
end

get("/admin/tags") do
    tags = get_data_base().execute("SELECT * from tag")
    slim(:tags, locals:{tags:tags})
end