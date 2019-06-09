def buildings_table(db)
    db.create_table? :buildings do
        primary_key :pid
        String :name
        String :code
        String :id
        Float :long
        Float :lat
    end

    db[:buildings]
end