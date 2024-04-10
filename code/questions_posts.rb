require_relative "all_of.rb"

# Creates a new question and redirects to all questions
#
# @param [String] title, The question
#
# @see Model#add_question
post("/questions") do
    user_id = session[:id]
    title = params[:title]
    time = Time.now.iso8601
    tags = params["tags"]

    if title.length > $QUESTION_TITLE_MAX_LENGTH
        redirect("/questions")
    end

    add_question(user_id, title, time, tags)

    redirect("/questions")
end

# Tries to increase the user's vote on an question and redirects to all questions
#
# @param [Integer] id, The id of the question
#
# @see Model#get_user_question_vote_value
# @see Model#update_user_question_vote_value
# @see Model#update_question_points
post("/questions/:id/upvote") do
    id = params[:id]
    if (get_user_question_vote_value(session[:id], id) < 1)
        update_user_question_vote_value(session[:id], id, 1)
        update_question_points(id, 1)
    end
    redirect("/questions")
end

# Tries to lower the user's vote on an question and redirects to all questions
#
# @param [Integer] id, The id of the question
#
# @see Model#get_user_question_vote_value
# @see Model#update_user_question_vote_value
# @see Model#update_question_points
post("/questions/:id/downvote") do
    id = params[:id]
    if (get_user_question_vote_value(session[:id], id) > -1)
        update_user_question_vote_value(session[:id], id, -1)
        update_question_points(id, -1)
    end
    redirect("/questions")
end

# Tries to delete a question and redirects to all questions
#
# @param [Integer] id, The id of the question
#
# @see Model#remove_question
post("/questions/:id/delete") do
    if (!session[:is_admin])
        redirect("/questions")
    end

    remove_question(params[:id])
    
    redirect("/questions")
end

# Changes the session's question sorting mode to points and redirects to all questions 
#
post("/questions/sort/points") do
    s = session[:question_sort_by]
    if s == "points_descending"
        session[:question_sort_by] = "points_ascending"
    else
        session[:question_sort_by] = "points_descending"
    end
    redirect("/questions")
end

# Changes the session's question sorting mode to time and redirects to all questions 
#
post("/questions/sort/time") do
    s = session[:question_sort_by]
    if s == "time_descending"
        session[:question_sort_by] = "time_ascending"
    else
        session[:question_sort_by] = "time_descending"
    end
    redirect("/questions")
end