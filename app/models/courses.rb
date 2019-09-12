$DB.create_table? :courses do
    primary_key :pid
    String :course_id
    Integer :semester
    String :name
    String :dept_id
    String :department
    String :credits
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

class Course < Sequel::Model
    def to_v0
        {
            course_id: course_id,
            semester: semester,
            name: name,
            dept_id: dept_id,
            department: department,
            credits: credits,
            description: description,
            grading_method: grading_method,
            gen_ed: gen_ed,
            core: core,
            relationships: relationships
        }
    end

    def t0_v0_info
        {
            course_id: course_id,
            dept_id: dept_id,
            name: name
        }
    end
end

class Section < Sequel::Model
    def to_v0
        {
            course_id: course_id,
            section_id: section_id,
            semester: semester.to_s,
            number: number,
            seats: seats,
            meetings: meetings,
            open_seats: open_seats,
            waitlist: waitlist,
            instructors: instructors
        }
    end
end

class Professor < Sequel::Model
    def to_v0
        {
            name: name,
            semester: semester,
            courses: courses,
            department: department
        }
    end
end