post("/answers/:question_id") do
    user_id = session[:id]
    answer_text = params[:answer_text]
    question_id = params[:question_id]
    time = Time.now.iso8601

    if answer_text.length > $ANSWER_TEXT_MAX_LENGTH
        redirect("/questions/#{question_id}")
    end
    
    add_answer(question_id, user_id, answer_text, time)

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

post("/answers/:id/delete") do
    if (!session[:is_admin])
        redirect("/questions")
    end

    id = params[:id]
    question_url = get_questionurl_from_answer(id)
    
    remove_answer(id)

    redirect(question_url)
end