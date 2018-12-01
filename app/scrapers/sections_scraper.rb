# Scrapes sections and puts them into mongo

require 'open-uri'
require 'nokogiri'
require 'mongo'
require 'pg'

require_relative '../helpers/courses_helpers.rb'
include Sinatra::UMDIO::Helpers

require_relative 'scraper_common.rb'
include ScraperCommon

# Parses a given section page
# Returns [sections, professors]
# TODO: Remove semester param, infer from url
def parse_sections(url, semester)
  # Parse with Nokogiri
  page = Nokogiri::HTML(open(url))
  course_divs = page.search("div.course-sections")
  section_array = []
  profs = {} # hash of professor => array of courses

  # for each of the courses on the page
  course_divs.each do |course_div|
    course_id = course_div.attr('id')
    # for each section of the course
    course_div.search("div.section").each do |section|
      # add section to array to add
      instructors = section.search('span.section-instructors').text.gsub(/\t|\r\n/,'').encode('UTF-8', :invalid => :replace).split(',').map(&:strip)
      dept = course_id.match(/^([A-Z]{4})\d{3}[A-Z]?$/)[1]

      # add course and department to professor object for each instructor
      instructors.each do |x|
        if x != 'Instructor: TBA'
          professor_name = x.squeeze(' ')
          profs[professor_name] ||= {:courses => [], :depts => []}
          profs[professor_name][:courses] |= [course_id]
          profs[professor_name][:depts] |= [dept]
        end
      end

      meetings = []
      section.search('div.class-days-container div.row').each do |meeting|
        start_time = meeting.search('span.class-start-time').text
        end_time = meeting.search('span.class-end-time').text

        meetings << {
          :days => meeting.search('span.section-days').text,
          :start_time => start_time,
          :end_time => end_time,
          :start_seconds => time_to_int(start_time),
          :end_seconds => time_to_int(end_time),
          :building => meeting.search('span.building-code').text,
          :room => meeting.search('span.class-room').text,
          :classtype => meeting.search('span.class-type').text || "Lecture"
        }
      end
      number = section.search('span.section-id').text.gsub(/\s/, '')
      open_seats = section.search('span.open-seats-count').text
      waitlist = section.search('span.waitlist-count').text
      section_array << {
        :section_id => "#{course_id}-#{number}",
        :course_id => course_id,
        :number => number,
        :instructors => section.search('span.section-instructors').text.gsub(/\t|\r\n/,'').encode('UTF-8', :invalid => :replace).split(',').map(&:strip),
        :seats  => section.search('span.total-seats-count').text,
        :semester => semester,
        :meetings => meetings,
        :open_seats => open_seats,
        :waitlist => waitlist
      }
    end
  end

  # Sort profs
  profs = profs.sort
  return [section_array, profs]
end

# Generatres prepared statements for inserting sections and profs into a semester
def prepare_statements(db, semester)
  db.prepare(
    "insert_#{semester}",
    "INSERT INTO sections#{semester} (
      section_id,
      course_id,
      number,
      instructors,
      seats,
      semester,
      meetings,
      open_seats,
      waitlist
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) ON CONFLICT (section_id) DO UPDATE SET
      section_id = $1,
      course_id = $2,
      number = $3,
      instructors = $4,
      seats = $5,
      semester = $6,
      meetings = $7,
      open_seats = $8,
      waitlist = $9"
  )

  db.prepare("insert_prof_#{semester}", "INSERT INTO professors (name, semester, courses, departments)
  VALUES ($1, $2, $3, $4) ON CONFLICT (name) DO UPDATE SET
  name = $1,
  semester = $2,
  courses = $3,
  departments = $4")
end

# Inital setup
prog_name = "sections_scraper"
logger = ScraperCommon::logger
db = ScraperCommon::postgres

semesters = ScraperCommon::get_semesters(ARGV)
courses = []

# Loop through the semesters we want to parse
semesters.each do |semester|
  # Arrays to hold the things we want to insert
  sections = []
  profs = []

  # Create our tables, if they don't exist
  db.exec("CREATE TABLE IF NOT EXISTS sections#{semester} ( like sections including all)")
  db.exec("CREATE TABLE IF NOT EXISTS professors#{semester} ( like professors including all)")

  # Prepare inserts
  prepare_statements(db, semester)
  logger.info(prog_name) {"Searching for sections in term #{semester}"}

  # Loop through all courses from that semester's courses table
  db.exec("SELECT * FROM courses#{semester}") do |result|
    result.each do |row|
      course_id = row.values_at('course_id')
      courses << course_id

      # Every 200, parse a sections page, reset courses
      if courses.length == 200
        query = "https://ntst.umd.edu/soc/#{semester}/sections?courseIds=#{courses.map{|e| e}.join(',')}"
        res = parse_sections(query, semester)
        courses = []
        sections.concat(res[0])
        profs.concat(res[1])
      end
    end

    # parse the last entries
    query = "https://ntst.umd.edu/soc/#{semester}/sections?courseIds=#{courses.map{|e| e}.join(',')}"
    res = parse_sections(query, semester)
    sections.concat(res[0])
    profs.concat(res[1])
    courses = []
  end

  # Now, insert all our stuff to the db
  sections.each do |section|
    db.exec_prepared("insert_#{semester}", [
      section[:section_id],
      section[:course_id],
      section[:number],
      PG::TextEncoder::Array.new.encode(section[:instructors]),
      section[:seats],
      section[:semester],
      PG::TextEncoder::JSON.new.encode(section[:meetings]),
      section[:open_seats],
      section[:waitlist]
    ])
  end

  profs.each do |prof|
    db.exec_prepared("insert_prof_#{semester}", [
      prof[0],
      PG::TextEncoder::Array.new.encode([semester]),
      PG::TextEncoder::Array.new.encode(prof[1][:courses]),
      PG::TextEncoder::Array.new.encode(prof[1][:depts])
    ])
  end
end
