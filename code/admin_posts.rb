# Adds a tag and redirects to admin/tags
#
# @param [String] name, The name of the tag
#
post("/admin/tags") do
    name = params[:name]
    get_data_base().execute("INSERT INTO tag (name) VALUES (?)", name)
    redirect("/admin/tags")
end