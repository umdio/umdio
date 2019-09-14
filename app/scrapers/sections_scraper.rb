# Scrapes sections and puts them into mongo

require 'open-uri'
require 'nokogiri'

require_relative '../helpers/courses_helpers.rb'
include Sinatra::UMDIO::Helpers

require_relative 'scraper_common.rb'
include ScraperCommon

require_relative '../models/courses.rb'

# Parses a given section page
# Returns [sections, professors]
# TODO: Remove semester param, infer from url
def parse_sections(url, semester)
  # Parse with Nokogiri
  page = Nokogiri::HTML(open(url))
  course_divs = page.search("div.course-sections")
  section_array = []

  # for each of the courses on the page
  course_divs.each do |course_div|
    course_id = course_div.attr('id')
    # for each section of the course
    course_div.search("div.section").each do |section|
      # add section to array to add
      instructors = section.search('span.section-instructors').text.gsub(/\t|\r\n/,'').encode('UTF-8', :invalid => :replace).split(',').map(&:strip)
      dept = course_id.match(/^([A-Z]{4})\d{3}[A-Z]?$/)[1]

      # add course and department to professor object for each instructor
      profs = []
      instructors.each do |x|
        if x != 'Instructor: TBA'
          professor_name = x.squeeze(' ')
          profs << professor_name
        end
      end

      meetings = []
      section.search('div.class-days-container div.row').each do |meeting|
        start_time = meeting.search('span.class-start-time').text
        end_time = meeting.search('span.class-end-time').text

        meetings << {
          days: meeting.search('span.section-days').text,
          start_time: start_time,
          end_time: end_time,
          start_seconds: time_to_int(start_time),
          end_seconds: time_to_int(end_time),
          building: meeting.search('span.building-code').text,
          room: meeting.search('span.class-room').text,
          classtype: meeting.search('span.class-type').text || "Lecture"
        }
      end
      number = section.search('span.section-id').text.gsub(/\s/, '')
      open_seats = section.search('span.open-seats-count').text
      waitlist = section.search('span.waitlist-count').text
      section_array << {
        section_id: "#{course_id}-#{number}",
        course_id: course_id,
        number: number,
        instructors: profs,
        seats: section.search('span.total-seats-count').text,
        semester: semester,
        meetings: meetings,
        open_seats: open_seats,
        waitlist: waitlist
      }
    end
  end

  return section_array
end

# Inital setup
prog_name = "sections_scraper"
logger = ScraperCommon::logger

semesters = ScraperCommon::get_semesters(ARGV)
courses = []

# Loop through the semesters we want to parse
semesters.each do |semester|
  # Arrays to hold the things we want to insert
  sections = []

  logger.info(prog_name) {"Searching for sections in term #{semester}"}

  # Loop through all courses from that semester's courses table
  $DB[:courses].where(semester: semester).each do |row|
    course_id = row[:course_id]
    courses << course_id

    # Every 200, parse a sections page, reset courses
    if courses.length == 200
      query = "https://ntst.umd.edu/soc/#{semester}/sections?courseIds=#{courses.map{|e| e}.join(',')}"
      res = parse_sections(query, semester)
      courses = []
      sections.concat(res)
    end
  end

    # parse the last entries
    query = "https://ntst.umd.edu/soc/#{semester}/sections?courseIds=#{courses.map{|e| e}.join(',')}"
    res = parse_sections(query, semester)
    sections.concat(res)
    courses = []

  # Now, insert all our stuff to the db
  sections.each do |section|
    section_key = $DB[:sections].insert_ignore.insert(
      :section_id => section[:section_id],
      :course_id => section[:course_id],
      :semester => section[:semester],
      :number => section[:number],
      :seats => section[:seats],
      :open_seats => section[:open_seats],
      :waitlist => section[:waitlist],
      :instructors => Sequel.pg_jsonb_wrap(section[:instructors])
    )

    section[:meetings].each do |meeting|
      $DB[:meetings].insert_ignore.insert(
        :section_key => section_key,
        :days => meeting[:days],
        :room => meeting[:room],
        :building => meeting[:building],
        :classtype => meeting[:classtype],
        :start_time => meeting[:start_time],
        :end_time => meeting[:end_time],
        :start_seconds => meeting[:start_seconds],
        :end_seconds => meeting[:end_seconds]
      )
    end

  section[:instructors].each do |prof|
    profs = Professor.where(name: prof).map{|p| p.to_v0}

    if profs.length > 1
      raise "Prof uniqueness violated"
    end

    if profs.length == 0
      $DB[:professors].insert(
        :name => prof,
        :semester => Sequel.pg_jsonb_wrap([section[:semester]]),
        :courses => Sequel.pg_jsonb_wrap([section[:course_id]]),
        :department => Sequel.pg_jsonb_wrap([section[:course_id][0,4]])
      )
    else
      sems = Sequel.pg_jsonb_wrap(profs[0][:semester].to_a.push(section[:semester]).uniq)
      courses = Sequel.pg_jsonb_wrap(profs[0][:courses].to_a.push(section[:course_id]).uniq)
      depts = Sequel.pg_jsonb_wrap(profs[0][:depts].to_a.push(section[:course_id][0,4]).uniq)

      $DB[:professors].insert_conflict(target: :name, update: {semester: sems, courses: courses, department: depts}).insert(
        :name => prof,
        :semester => Sequel.pg_jsonb_wrap([section[:semester]]),
        :courses => Sequel.pg_jsonb_wrap([section[:course_id]]),
        :department => Sequel.pg_jsonb_wrap([section[:course_id][0,4]])
      )
    end
  end
end
end