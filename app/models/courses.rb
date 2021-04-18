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
  String :gen_ed
  column :core, :jsonb
  column :relationships, :jsonb
  unique [:course_id, :semester]
end


$DB.create_table? :sections do
  primary_key :section_id
  String :section_id_str
  String :course_id
  Integer :semester
  String :number
  String :seats
  String :open_seats
  String :waitlist
  unique [:section_id_str, :course_id, :semester]
end

$DB.create_table? :meetings do
  primary_key :meeting_key
  foreign_key :section_key
  String :days
  String :room
  String :building
  String :classtype
  String :start_time
  String :end_time
  Integer :start_seconds
  Integer :end_seconds
end


$DB.create_table? :professors do
  primary_key :professor_id
  String :name, {:unique => true}
end

$DB.create_join_table?(:professor_id=>:professors, :section_id=>:sections)

class Course < Sequel::Model
  dataset_module do
    def all_semesters
      Course.distinct(:semester).map {|c| c[:semester]}.sort
    end

    def all_depts
      Course.distinct(:dept_id, :department).map {|c| {dept_id: c[:dept_id], department: c[:department]}}.sort_by! {|d| d[:dept_id]}
    end

    def list_sem semester
      Course.where(semester: semester).order(Sequel.asc(:course_id))
    end
  end

  def to_v1
    # gen_ed = "DSHS or DSSP, SCIS"
    puts gen_ed.class
    gen_ed = gen_ed.gsub(/\s/, '')
    ge = []
    choose_from = []
    always_given = []

    if gen_ed.include?('or')
      choose_from = gen_ed.split(',')[0].split('or')
      always_given = gen_ed.split(',')[1..-1]
    end

    if choose_from == []
      ge << always_given
    else
      choose_from.each do |ge_chosen|
        ge << always_given + [ge_chosen]
      end
    end

    {
      course_id: course_id,
      semester: semester.to_s,
      name: name,
      dept_id: dept_id,
      department: department,
      credits: credits,
      description: description,
      grading_method: grading_method,
      gen_ed: ge,
      core: core,
      relationships: relationships
    }
  end

  def to_v1_info
    {
      course_id: course_id,
      name: name
    }
  end

  def to_v0
    {
      course_id: course_id,
      semester: semester.to_s,
      name: name,
      dept_id: dept_id,
      department: department,
      credits: credits,
      description: description,
      grading_method: grading_method,
      gen_ed: gen_ed.gsub(/\s/, '').gsub("iftakenwith","fkwh").split(','),
      core: core,
      relationships: relationships
    }
  end

  def to_v0_info
    {
      course_id: course_id,
      dept_id: dept_id,
      name: name
    }
  end
end

class Meeting < Sequel::Model
  def to_v1
    {
      days: days,
      room: room,
      building: building,
      classtype: classtype,
      start_time: start_time,
      end_time: end_time
    }
  end

  def to_v0
    {
      days: days,
      room: room,
      building: building,
      classtype: classtype,
      start_time: start_time,
      end_time: end_time
    }
  end
end

class Section < Sequel::Model
  one_to_many :meetings, key: :section_key
  many_to_many :professors

  def to_v1
    profs = professors.map {|p| p[:name]}

    {
      course: course_id,
      section_id: section_id_str,
      semester: semester.to_s,
      number: number,
      seats: seats,
      meetings: meetings.map {|m| m.to_v1},
      open_seats: open_seats,
      waitlist: waitlist,
      instructors: profs
    }
  end

  def to_info
    {
      course: course_id,
      semester: semester.to_s
    }
  end

  def to_v0
    profs = professors.map {|p| p[:name]}

    {
      course: course_id,
      section_id: section_id_str,
      semester: semester.to_s,
      number: number,
      seats: seats,
      meetings: meetings.map {|m| m.to_v0},
      open_seats: open_seats,
      waitlist: waitlist,
      instructors: profs
    }
  end
end

class Professor < Sequel::Model
  many_to_many :sections

  def to_v0
    ss = sections.map{|s| s.to_info}
    semesters = []
    courses = []
    depts = []

    ss.each {|s|
      if s[:course]
        semesters << s[:semester]
        courses << s[:course]
        depts << s[:course][0..3]
      end
    }

    {
      name: name,
      semester: semesters.uniq,
      courses: courses.uniq,
      department: depts.uniq
    }
  end

  def to_v1
    ss = sections.map{|s| s.to_info}
    taught = []

    ss.each {|s|
      if s[:course]
        taught << {course_id: s[:course], semester: s[:semester]}
      end
    }

    {
      name: name,
      taught: taught.uniq
    }
  end
end
