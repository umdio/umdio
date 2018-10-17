# Scrapes sections and puts them into mongo

require 'open-uri'
require 'nokogiri'
require 'mongo'

require_relative '../helpers/courses_helpers.rb'
include Sinatra::UMDIO::Helpers

require_relative 'scraper_common.rb'
include ScraperCommon

prog_name = "sections_scraper"

logger = ScraperCommon::logger
db = ScraperCommon::database 'umdclass'


# Find all the course collections
course_collections = db.collection_names().select { |e| e.include?('courses') }.map { |name| db.collection(name) }
section_queries = []

num_groups = 0

# Find the sections we have to parse
course_collections.each do |c|
  semester = c.name.scan(/courses(.+)/)[0]
  if not semester.nil?
    semester = semester[0]
    c.find({},{fields: {_id:0,course_id:1}}).to_a
      .each_slice(200){|a|
      num_groups += 1
        section_queries << "https://ntst.umd.edu/soc/#{semester}/sections?courseIds=#{a.map{|e| e['course_id']}.join(',')}"
      }
  end
end

count = 0
total = 0

# Parse section data from pages
section_queries.each do |query|
  # Get needed Mongo collections
  semester = query.scan(/soc\/(.+)\//)[0][0]
  sections_coll = db.collection("sections#{semester}")
  prof_coll = db.collection("profs#{semester}")
  sections_bulk = sections_coll.initialize_unordered_bulk_op
  prof_bulk = prof_coll.initialize_unordered_bulk_op

  # Parse with Nokogiri
  page = Nokogiri::HTML(open(query))
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
      section_array << {
        :section_id => "#{course_id}-#{number}",
        :course => course_id,
        :number => number,
        :instructors => section.search('span.section-instructors').text.gsub(/\t|\r\n/,'').encode('UTF-8', :invalid => :replace).split(',').map(&:strip),
        :seats  => section.search('span.total-seats-count').text,
        :semester => semester,
        :meetings => meetings
      }
      total += 1
    end
  end

  count += 1

  logger.info(prog_name) {"inserting set number #{count} of sections. #{num_groups - count} sets remaining - #{semester} term. #{total} total."}

  section_array.each do |section|
    sections_bulk.find({section_id: section[:section_id]}).upsert.update({ "$set" => section })
  end
  sections_bulk.execute unless section_array.empty?

  # sorts profs by name, insert to db
  profs.sort.to_h.each do |name, obj|
    courses = obj[:courses]
    depts = obj[:depts]
    # push all courses to prof's entry
    prof_bulk.find({name: name}).upsert.update(
      {"$set" => {name: name},
       "$addToSet" => {semester: semester, courses: {"$each" => courses}, departments: {"$each" => depts} }
      }
  )
  end
  prof_bulk.execute unless profs.empty?
end