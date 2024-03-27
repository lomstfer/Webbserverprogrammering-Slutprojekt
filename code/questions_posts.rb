require_relative "all_of.rb"

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

    remove_question(params[:id])
    
    redirect("/questions")
end


post("/questions/sort/points") do
    s = session[:question_sort_by]
    if s == "points_descending"
        session[:question_sort_by] = "points_ascending"
    else
        session[:question_sort_by] = "points_descending"
    end
    redirect("/questions")
end

post("/questions/sort/time") do
    s = session[:question_sort_by]
    if s == "time_descending"
        session[:question_sort_by] = "time_ascending"
    else
        session[:question_sort_by] = "time_descending"
    end
    redirect("/questions")
end