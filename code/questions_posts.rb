require_relative "all_of.rb"

post("/questions") do
    user_id = session[:id]
    title = params[:title]
    time = Time.now.iso8601

    db = get_data_base()
    db.execute("INSERT INTO question (user_id, title, time_created) VALUES (?, ?, ?)", user_id, title, time)
    
    question_id = db.last_insert_row_id()
    params["tags"].each do |tag_id|
        db.execute("INSERT INTO question_tag_relation (question_id, tag_id) VALUES (?, ?)", question_id, tag_id)
    end

    redirect("/questions")
end

post("/questions/:id/upvote") do
    id = params[:id]
    if (get_user_question_vote_value(session[:id], id) < 1)
        update_user_question_vote_value(session[:id], id, 1)
        update_question_points(id, 1)
    end
    redirect("/questions")
end

post("/questions/:id/downvote") do
    id = params[:id]
    if (get_user_question_vote_value(session[:id], id) > -1)
        update_user_question_vote_value(session[:id], id, -1)
        update_question_points(id, -1)
    end
    redirect("/questions")
end

post("/questions/:id/delete") do
    if (!session[:is_admin])
        redirect("/questions")
    end
    
    id = params[:id]
    get_data_base().execute("DELETE FROM question WHERE id = (?)", id)

    redirect("/questions")
end

def update_question_points(id, points_to_add)
    prev_points = get_data_base().execute("SELECT points FROM question WHERE id = (?)", id).first["points"]
    new_points = (prev_points.to_i + points_to_add).to_s
    get_data_base().execute("UPDATE question SET points = (?) WHERE id = (?)", new_points, id)
end

def get_user_question_vote_value(user_id, question_id)
    vote = get_data_base().execute("SELECT * FROM user_question_vote WHERE user_id = (?) AND question_id = (?)", user_id, question_id).first
    if (vote == nil)
        get_data_base().execute("INSERT INTO user_question_vote (user_id, question_id, vote_value) VALUES (?, ?, ?)", user_id, question_id, 0)
        return 0
    end
    return vote["vote_value"]
end

def update_user_question_vote_value(user_id, question_id, vote_value_to_add)
    vote = get_data_base().execute("SELECT * FROM user_question_vote WHERE user_id = (?) AND question_id = (?)", user_id, question_id).first
    if (vote == nil)
        get_data_base().execute("INSERT INTO user_question_vote (user_id, question_id, vote_value) VALUES (?, ?, ?)", user_id, question_id, vote_value_to_add)
        return
    end
    prev_vote_value = get_data_base().execute("SELECT vote_value FROM user_question_vote WHERE user_id = (?) AND question_id = (?)", user_id, question_id).first["vote_value"]
    new_vote_value = (prev_vote_value.to_i + vote_value_to_add).to_s
    get_data_base().execute("UPDATE user_question_vote SET vote_value = (?) WHERE user_id = (?) AND question_id = (?)", new_vote_value, user_id, question_id)
end