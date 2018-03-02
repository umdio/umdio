# script for adding sections of umd classes to mongo
# 4min on the VM

require 'open-uri'
require 'nokogiri'
require 'mongo'
include Mongo
require_relative '../helpers/courses_helpers.rb'
include Sinatra::UMDIO::Helpers

# Connect to MongoDB, if no port specified it picks the default
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] ? ':' + ENV['MONGO_RUBY_DRIVER_PORT'] : ''

puts "Connecting to #{host}:#{port}"
db = Mongo::Client.new("mongodb://#{host}#{port}/umdclass")

# Architecture:
# build list of queries
course_collections = db.database.collection_names().select { |e| e.include?('courses') }.map { |name| db[name] }
section_queries = []
course_collections.each do |c|
  semester = c.name.scan(/courses(.+)/)[0]
  if not semester.nil?
    semester = semester[0]
    c.find({},{fields: {_id:0,course_id:1}}).to_a
      .each_slice(200){|a| section_queries <<
        "https://ntst.umd.edu/soc/#{semester}/sections?courseIds=#{a.map{|e| e['course_id']}.join(',') }"
      }
  end
end

puts "Scraping sections"
count = 0
total = 0
# Parse section data from pages
section_queries.each do |query|
  semester = query.scan(/soc\/(.+)\//)[0][0]
  sections_coll = db["sections#{semester}"]
  prof_coll = db["profs#{semester}"]

  sections_bulk = []
  prof_bulk = []

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
        profs[x] ||= {:courses => [], :depts => []}
        profs[x][:courses] |= [course_id]
        profs[x][:depts] |= [dept]
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

  # insert array of sections into mongo
  count += 1

  # nitpick: should be 'courses', not sure how many sections we're adding
  # puts "inserting set number #{count} of sections. 200 more sections in the database - #{semester} term. #{total} total."
  puts "inserting set number #{count} of sections. 200 more courses in the database - #{semester} term. #{total} total."

  # Should be upsert not insert, so we can run multiple times without having to drop the database
  # coll.insert(section_array) unless section_array.empty?
  section_array.each do |section|
    sections_bulk << { :update_one => {
      :filter => { :section_id => section[:section_id] },
      :update => {'$set' => { :section => section[:section_id] }},
      :upsert => true
    }}
  end
  sections_coll.bulk_write(sections_bulk, {:ordered => false}) unless section_array.empty?

  # sorts profs by name, insert to db
  profs.sort.to_h.each do |name, obj|
    courses = obj[:courses]
    depts = obj[:depts]

    # push all courses to prof's entry
    prof_bulk << { :update_one => {
      :filter => { :name => name },
      :update => {
        '$set' => { :name => name },
        "$addToSet" => {semester: semester, courses: {"$each" => courses}, departments: {"$each" => depts} }
      },
      :upsert => true
    }}
  end
  prof_coll.bulk_write(prof_bulk, {:ordered => false}) unless profs.empty?
end