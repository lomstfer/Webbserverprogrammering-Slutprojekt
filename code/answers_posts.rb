# Creates a new answer and redirects to its question
#
# @param [String] answer_text, The body of the answer
# @param [Integer] question_id, The id of the question the answer belongs to
#
# @see Model#add_answer
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

# Tries to increase the user's vote on an answer and redirects to the question
#
# @param [Integer] id, The id of the answer
#
# @see Model#get_user_answer_vote_value
# @see Model#update_user_answer_vote_value
# @see Model#update_answer_points
# @see Model#get_questionurl_from_answer
post("/answers/:id/upvote") do
    id = params[:id]
    if (get_user_answer_vote_value(session[:id], id) < 1)
        update_user_answer_vote_value(session[:id], id, 1)
        update_answer_points(id, 1)
    end
    url = get_questionurl_from_answer(id)
    redirect(url)
end

# Tries to lower the user's vote on an answer and redirects to the question
#
# @param [Integer] id, The id of the answer
#
# @see Model#get_user_answer_vote_value
# @see Model#update_user_answer_vote_value
# @see Model#update_answer_points
# @see Model#get_questionurl_from_answer
post("/answers/:id/downvote") do
    id = params[:id]
    if (get_user_answer_vote_value(session[:id], id) > -1)
        update_user_answer_vote_value(session[:id], id, -1)
        update_answer_points(id, -1)
    end
    url = get_questionurl_from_answer(id)
    redirect(url)
end

# Deletes an answer and redirects to the question
#
# @param [Integer] id, The id of the answer
#
# @see Model#get_questionurl_from_answer
# @see Model#remove_answer
post("/answers/:id/delete") do
    id = params[:id]

    question_url = get_questionurl_from_answer(id)

    if (!session[:is_admin] && !user_owns_answer?(session[:id], id))
        redirect(question_url)
    end
    
    remove_answer(id)

    redirect(question_url)
end