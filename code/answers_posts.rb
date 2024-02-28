post("/answers/:question_id") do
    user_id = session[:id]
    answer_text = params[:answer_text]
    question_id = params[:question_id]
    time = Time.now.iso8601
    
    get_data_base().execute("INSERT INTO answer (question_id, user_id, answer_text, time_created) VALUES (?, ?, ?, ?)", question_id, user_id, answer_text, time)
    
    redirect("/questions/#{question_id}")
end

post("/answers/:id/upvote") do
    id = params[:id]
    if (get_user_answer_vote_value(session[:id], id) < 1)
        update_user_answer_vote_value(session[:id], id, 1)
        update_answer_points(id, 1)
    end
    url = get_questionurl_from_answer(id)
    redirect(url)
end

post("/answers/:id/downvote") do
    id = params[:id]
    if (get_user_answer_vote_value(session[:id], id) > -1)
        update_user_answer_vote_value(session[:id], id, -1)
        update_answer_points(id, -1)
    end
    url = get_questionurl_from_answer(id)
    redirect(url)
end

def update_answer_points(id, points_to_add)
    prev_points = get_data_base().execute("SELECT points FROM answer WHERE id = (?)", id).first["points"]
    new_points = (prev_points.to_i + points_to_add).to_s
    get_data_base().execute("UPDATE answer SET points = (?) WHERE id = (?)", new_points, id)
end

def get_questionurl_from_answer(answer_id)
    question_id = get_data_base().execute("SELECT question_id FROM answer WHERE id = (?)", answer_id).first["question_id"]
    return "/questions/#{question_id}"
end

def get_user_answer_vote_value(user_id, answer_id)
    vote = get_data_base().execute("SELECT * FROM user_answer_vote WHERE user_id = (?) AND answer_id = (?)", user_id, answer_id).first
    if (vote == nil)
        get_data_base().execute("INSERT INTO user_answer_vote (user_id, answer_id, vote_value) VALUES (?, ?, ?)", user_id, answer_id, 0)
        return 0
    end
    return vote["vote_value"]
end

def update_user_answer_vote_value(user_id, answer_id, vote_value_to_add)
    vote = get_data_base().execute("SELECT * FROM user_answer_vote WHERE user_id = (?) AND answer_id = (?)", user_id, answer_id).first
    if (vote == nil)
        get_data_base().execute("INSERT INTO user_answer_vote (user_id, answer_id, vote_value) VALUES (?, ?, ?)", user_id, answer_id, vote_value_to_add)
        return
    end
    prev_vote_value = get_data_base().execute("SELECT vote_value FROM user_answer_vote WHERE user_id = (?) AND answer_id = (?)", user_id, answer_id).first["vote_value"]
    new_vote_value = (prev_vote_value.to_i + vote_value_to_add).to_s
    get_data_base().execute("UPDATE user_answer_vote SET vote_value = (?) WHERE user_id = (?) AND answer_id = (?)", new_vote_value, user_id, answer_id)
end