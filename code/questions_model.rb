def add_question(user_id, title, time, tags)
    db = get_data_base()
    db.execute("INSERT INTO question (user_id, title, time_created) VALUES (?, ?, ?)", user_id, title, time)
    
    question_id = db.last_insert_row_id()
    if tags
        tags.each do |tag_id|
            db.execute("INSERT INTO question_tag_relation (question_id, tag_id) VALUES (?, ?)", question_id, tag_id)
        end
    end
end

def remove_question(id)
    get_data_base().execute("DELETE FROM question WHERE id = (?)", id)
end

def set_owner_and_tags_on_questions(questions)
    db = get_data_base()
    questions.each do |q|
        q["owner"] = db.execute("SELECT username FROM user WHERE id = (?)", q["user_id"]).first["username"]
        
        tags_on_question = db.execute("
            SELECT name
            FROM tag
            INNER JOIN question_tag_relation ON question_tag_relation.tag_id = tag.id
            WHERE question_id = (?)",
            q["id"])
        q["tags"] = []
        tags_on_question.each do |t|
            q["tags"].push(t["name"])
        end
    end
end

def set_tags_on_question(question)
    db = get_data_base()
    tags_on_question = db.execute("
        SELECT name
        FROM tag
        INNER JOIN question_tag_relation ON question_tag_relation.tag_id = tag.id
        WHERE question_id = (?)",
        question["id"])
    question["tags"] = []
    tags_on_question.each do |t|
        question["tags"].push(t["name"])
    end
end

def sort_questions(sort_by, questions)
    if sort_by != nil
        if sort_by == "points_descending"
            questions.sort_by!{|q| -q["points"]}
        elsif sort_by == "points_ascending"
            questions.sort_by!{|q| q["points"]}
        elsif sort_by == "time_descending"
            questions.sort_by! do |q|
                time = Time.parse(q["time_created"])
                time_since_epoch = time.to_i
                -time_since_epoch
            end
        elsif sort_by == "time_ascending"
            questions.sort_by! do |q|
                time = Time.parse(q["time_created"])
                time_since_epoch = time.to_i
                time_since_epoch
            end
        end
    end
end

def get_questions()
    return get_data_base().execute("SELECT * FROM question")
end

def get_question(id)
    return get_data_base().execute("SELECT * FROM question WHERE id = (?)", id).first
end

def get_username_from_user_id(user_id)
    return get_data_base().execute("SELECT username FROM user WHERE id = (?)", user_id).first["username"]
end

def update_question_points(id, points_to_add)
    prev_points = get_data_base().execute("SELECT points FROM question WHERE id = (?)", id).first["points"]
    new_points = (prev_points.to_i + points_to_add).to_s
    get_data_base().execute("UPDATE question SET points = (?) WHERE id = (?)", new_points, id)
end

def get_user_question_vote_value(user_id, question_id)
    vote = get_data_base().execute("SELECT * FROM user_question_vote WHERE user_id = (?) AND question_id = (?)", user_id, question_id).first
    if (vote == nil)
        get_data_base().execute("INSERT INTO user_question_vote (user_id, question_id, vote_value) VALUES (?, ?, ?)", user_id, question_id, 0)
        return 0
    end
    return vote["vote_value"]
end

def update_user_question_vote_value(user_id, question_id, vote_value_to_add)
    vote = get_data_base().execute("SELECT * FROM user_question_vote WHERE user_id = (?) AND question_id = (?)", user_id, question_id).first
    if (vote == nil)
        get_data_base().execute("INSERT INTO user_question_vote (user_id, question_id, vote_value) VALUES (?, ?, ?)", user_id, question_id, vote_value_to_add)
        return
    end
    prev_vote_value = get_data_base().execute("SELECT vote_value FROM user_question_vote WHERE user_id = (?) AND question_id = (?)", user_id, question_id).first["vote_value"]
    new_vote_value = (prev_vote_value.to_i + vote_value_to_add).to_s
    get_data_base().execute("UPDATE user_question_vote SET vote_value = (?) WHERE user_id = (?) AND question_id = (?)", new_vote_value, user_id, question_id)
end