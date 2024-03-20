post("/login_as_guest") do 
    session[:is_guest] = true
    redirect("/questions")
end