$DB.create_table? :courses do
    primary_key :pid
    String :course_id
    Integer :semester
    String :name
    String :dept_id
    String :department
    String :description
    column :grading_method, :jsonb
    column :gen_ed, :jsonb
    column :core, :jsonb
    column :relationships, :jsonb
    unique [:course_id, :semester]
end


$DB.create_table? :sections do
    primary_key :pid
    String :section_id
    String :course_id
    Integer :semester
    String :number
    String :seats
    column :meetings, :jsonb
    String :open_seats
    String :waitlist
    column :instructors, :jsonb
    unique [:section_id, :course_id, :semester]
end


$DB.create_table? :professors do
    primary_key :pid
    String :name, {:unique => true}
    column :semester, :jsonb
    column :courses, :jsonb
    column :department, :jsonb
end