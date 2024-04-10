# Sets is_guest to true in the session and redirects to all questions
#
post("/login_as_guest") do 
    session[:is_guest] = true
    redirect("/questions")
end