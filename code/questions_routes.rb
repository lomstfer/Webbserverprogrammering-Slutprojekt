require_relative "all_of.rb"

post("/questions") do
    user_id = session[:id]
    title = params[:title]
    time = Time.now.iso8601
    
    getDataBase().execute("INSERT INTO question (user_id, title, time_created) VALUES (?, ?, ?)", user_id, title, time)
    redirect("/questions")
end