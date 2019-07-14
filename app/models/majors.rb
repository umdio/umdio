def majors_table(db)
    db.create_table? :majors do
        primary_key :pid
        String :major_id
        String :name
        String :college
        String :url
    end

    db[:majors]
end