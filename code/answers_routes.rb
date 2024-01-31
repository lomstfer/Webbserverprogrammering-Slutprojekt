post("/answers/:question_id") do
    user_id = session[:id]
    answer_text = params[:answer_text]
    question_id = params[:question_id]
    time = Time.now.iso8601
    
    getDataBase().execute("INSERT INTO answer (question_id, user_id, answer_text, time_created) VALUES (?, ?, ?, ?)", question_id, user_id, answer_text, time)
    
    redirect("/questions/#{question_id}")
end