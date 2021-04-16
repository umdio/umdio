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
  # begin
  #   page = Nokogiri::HTML(URI::open(url))
  # rescue OpenURI::HTTPError => error
  #   logger.error("Error raised for url '#{url}': #{error.message}")
  #   raise
  # end
  page = ScraperCommon::get_page url, prog_name

  course_divs = page.search("div.course-sections")
  section_array = []

  # for each of the courses on the page
  course_divs.each do |course_div|
    course_id = course_div.attr('id')
    # for each section of the course
    course_div.search("div.section").each do |section|
      # add section to array to add
      instructors = section.search('span.section-instructors').text.gsub(/\t|\r\n/,'').encode('UTF-8', :invalid => :replace).split(',').map(&:strip)
      # note: some courses have weird suffixes (e.g. MSBB99MB, yes thats a real class)
      dept = course_id[0, 4]

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
# course id accumulator. Flushed each time a sections GET request is made.
# @type [Array<Number>]
courses = []

# Loop through the semesters we want to parse
semesters.each do |semester|
  # Arrays to hold the things we want to insert
  sections = []

  # TODO use this below
  # @param [Array<String | Number>] courses
  # @return [String]
  def make_query courses
    "https://app.testudo.umd.edu/soc/#{semester}/sections?courseIds=#{courses.map{|e| e}.join(',')}"
  end


  logger.info(prog_name) {"Searching for sections in term #{semester}"}

  # Loop through all courses from that semester's courses table
  $DB[:courses].where(semester: semester).each do |row|
    course_id = row[:course_id]
    courses << course_id

    # Every 200, parse a sections page, reset courses
    if courses.length == 200
      query = "https://app.testudo.umd.edu/soc/#{semester}/sections?courseIds=#{courses.map{|e| e}.join(',')}"

      res = parse_sections(query, semester)
      courses = []
      sections.concat(res)
    end
  end

    # parse the last entries
    query = "https://app.testudo.umd.edu/soc/#{semester}/sections?courseIds=#{courses.map{|e| e}.join(',')}"
    res = parse_sections(query, semester)
    sections.concat(res)
    courses = []

  # Now, insert all our stuff to the db
  sections.each do |section|
    $DB[:sections].insert_ignore.insert(
      :section_id_str => section[:section_id],
      :course_id => section[:course_id],
      :semester => section[:semester],
      :number => section[:number],
      :seats => section[:seats],
      :open_seats => section[:open_seats],
      :waitlist => section[:waitlist],
    )

    s = $DB[:sections].where(section_id_str: section[:section_id], course_id: section[:course_id], semester: section[:semester]).first

    section[:meetings].each do |meeting|
      $DB[:meetings].insert_ignore.insert(
        :section_key => s[:section_id],
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
    $DB[:professors].insert_ignore.insert(
      :name => prof,
    )

    pr = $DB[:professors].where(name: prof).first

    $DB[:professors_sections].insert_ignore.insert(
      :section_id => s[:section_id],
      :professor_id => pr[:professor_id]
    )
  end
end
end
