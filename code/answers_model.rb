module Model
    # Adds an answer into the database
    #
    # @param [Integer] question_id, the id of the answers question
    # @param [Integer] user_id, the id of answerer
    # @param [String] answer_text, the answer
    # @param [String] time, the time of when the answer was created
    #
    def add_answer(question_id, user_id, answer_text, time)
        get_data_base().execute("INSERT INTO answer (question_id, user_id, answer_text, time_created) VALUES (?, ?, ?, ?)", question_id, user_id, answer_text, time)
    end

    # Removes an answer from the database
    #
    # @param [Integer] id, the id of the answer
    def remove_answer(id)
        db = get_data_base()
        db.execute("DELETE FROM answer WHERE id = (?)", id)
        db.execute("DELETE FROM user_answer_vote WHERE answer_id = (?)", id)
    end

    # Adds/removes points from an answer
    #
    # @param [Integer] id, the id of the answer
    # @param [Integer] points_to_add, the points to add (can be negative)
    #
    def update_answer_points(id, points_to_add)
        prev_points = get_data_base().execute("SELECT points FROM answer WHERE id = (?)", id).first["points"]
        new_points = (prev_points.to_i + points_to_add).to_s
        get_data_base().execute("UPDATE answer SET points = (?) WHERE id = (?)", new_points, id)
    end

    # Gets the URL to the question that the answer belongs to
    #
    # @param [Integer] answer_id, the id of the answer
    #
    # @return [String] the URL
    def get_questionurl_from_answer(answer_id)
        question_id = get_data_base().execute("SELECT question_id FROM answer WHERE id = (?)", answer_id).first["question_id"]
        return "/questions/#{question_id}"
    end

    # Gets the value of the user's vote on an answer
    #
    # @param [Integer] user_id, the id of the user
    # @param [Integer] answer_id, the id of the answer
    #
    # @return [String] the value of the user's vote on the answer
    def get_user_answer_vote_value(user_id, answer_id)
        vote = get_data_base().execute("SELECT * FROM user_answer_vote WHERE user_id = (?) AND answer_id = (?)", user_id, answer_id).first
        if (vote == nil)
            get_data_base().execute("INSERT INTO user_answer_vote (user_id, answer_id, vote_value) VALUES (?, ?, ?)", user_id, answer_id, 0)
            return 0
        end
        return vote["vote_value"]
    end

    # Updates the user's vote value on an answer
    #
    # @param [Integer] user_id, the id of the user
    # @param [Integer] answer_id, the id of the answer
    # @param [Integer] vote_value_to_add, the points to add (can be nagative)
    #
    def update_user_answer_vote_value(user_id, answer_id, vote_value_to_add)
        vote = get_data_base().execute("SELECT * FROM user_answer_vote WHERE user_id = (?) AND answer_id = (?)", user_id, answer_id).first
        if (vote == nil)
            get_data_base().execute("INSERT INTO user_answer_vote (user_id, answer_id, vote_value) VALUES (?, ?, ?)", user_id, answer_id, vote_value_to_add)
            return
        end
        prev_vote_value = get_data_base().execute("SELECT vote_value FROM user_answer_vote WHERE user_id = (?) AND answer_id = (?)", user_id, answer_id).first["vote_value"]
        new_vote_value = (prev_vote_value.to_i + vote_value_to_add).to_s
        get_data_base().execute("UPDATE user_answer_vote SET vote_value = (?) WHERE user_id = (?) AND answer_id = (?)", new_vote_value, user_id, answer_id)
    end
    
    # Gets all answers of a question
    #
    # @param [Integer] question_id, the id of the question
    #
    # @return [Array] the answers
    def get_answers(question_id)
        return get_data_base().execute("SELECT * FROM answer WHERE question_id = (?)", question_id)
    end

    # Sets the owner (username) on each of the provided answers
    #
    # @param [Array] answers that are hashes
    #
    def set_owner_on_answers(answers)
        db = get_data_base()
        answers.each do |a|
            a["owner"] = db.execute("SELECT username FROM user WHERE id = (?)", a["user_id"]).first["username"]
        end
    end

end