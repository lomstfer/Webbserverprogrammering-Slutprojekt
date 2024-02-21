post("/answers/:question_id") do
    user_id = session[:id]
    answer_text = params[:answer_text]
    question_id = params[:question_id]
    time = Time.now.iso8601
    
    getDataBase().execute("INSERT INTO answer (question_id, user_id, answer_text, time_created) VALUES (?, ?, ?, ?)", question_id, user_id, answer_text, time)
    
    redirect("/questions/#{question_id}")
end

post("/answers/:id/upvote") do
    id = params[:id]
    update_answer_points(id, 1)
    url = get_questionurl_from_answer(id)
    redirect(url)
end

post("/answers/:id/downvote") do
    id = params[:id]
    update_answer_points(id, -1)
    url = get_questionurl_from_answer(id)
    redirect(url)
end

def update_answer_points(id, points_to_add)
    prev_points = getDataBase().execute("SELECT points FROM answer WHERE id = (?)", id).first["points"]
    new_points = (prev_points.to_i + points_to_add).to_s
    getDataBase().execute("UPDATE answer SET points = (?) WHERE id = (?)", new_points, id)
end

def get_questionurl_from_answer(answer_id)
    question_id = getDataBase().execute("SELECT question_id FROM answer WHERE id = (?)", answer_id).first["question_id"]
    return "/questions/#{question_id}"
end