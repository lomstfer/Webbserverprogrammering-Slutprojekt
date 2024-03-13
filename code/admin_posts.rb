post("/admin/tags") do
    name = params[:name]
    get_data_base().execute("INSERT INTO tag (name) VALUES (?)", name)
    redirect("/admin/tags")
end