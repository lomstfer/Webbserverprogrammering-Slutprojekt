require_relative "all_of.rb"

post("/questions") do
    user_id = session[:id]
    title = params[:title]
    time = Time.now.iso8601
    
    getDataBase().execute("INSERT INTO question (user_id, title, time_created) VALUES (?, ?, ?)", user_id, title, time)
    redirect("/questions")
end

post("/questions/:id/upvote") do
    id = params[:id]
    update_question_points(id, 1)
    redirect("/questions")
end

post("/questions/:id/downvote") do
    id = params[:id]
    update_question_points(id, -1)
    redirect("/questions")
end

def update_question_points(id, points_to_add)
    prev_points = getDataBase().execute("SELECT points FROM question WHERE id = (?)", id).first["points"]
    new_points = (prev_points.to_i + points_to_add).to_s
    getDataBase().execute("UPDATE question SET points = (?) WHERE id = (?)", new_points, id)
end