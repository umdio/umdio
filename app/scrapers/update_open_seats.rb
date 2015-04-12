# Update open seat information on sections in a mongo database
# Ran in 3 minutes on Rob's Laptop, updating the 6000 or so sections. 

ENV['RACK_ENV'] ||= 'scrape'

require 'open-uri'
require 'nokogiri'
require 'mongo'
include Mongo

#set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

#announce connection and connect8
puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port, pool_size: 2, pool_timeout: 2).db('umdclass')

# Read in a section from the command line
semester = ARGV[0]
total = 0
raise "#{semester} is not a semester in the sections database. Available collections: #{db.collection_names}" unless db.collection_names.include?("sections#{semester}")

c = db.collection("courses#{semester}")
sect = db.collection("sections#{semester}")

section_queries = []
c.find({},{fields: {_id:0,course_id:1}}).to_a.each_slice(200) do |a| 
  section_queries << "https://ntst.umd.edu/soc/#{semester}/sections?courseIds=#{a.map{|e| e['course_id']}.join(',')}"
end

section_queries.each do |query|
  count = 0
  # start the bulk mongo update operation
  bulk = sect.initialize_unordered_bulk_op
  course_ids = query.scan(/courseIds=(.+)/)[0][0].split(',')
  page = Nokogiri::HTML(open(query))

  # for each of the courses on the page
  course_ids.each do |course|
    course_div = page.css("##{course}") unless course.empty?
    # for each section of the course
    break if !course_div
    course_div.search("div.section").each do |sec_div|
      # find the open seat + waitlist info for the different sections
      sec_id = "#{course}-#{sec_div.search('span.section-id').text.strip}"
      open = sec_div.search("span.open-seats-count").text
      wait = sec_div.search("span.waitlist-count").text
      # build a mongo update
      count += 1
      total += 1
      print "."
      bulk.find({section_id: sec_id}).upsert().update( { "$set" => { open_seats: open, waitlist: wait} } ) 
    end
  end
  # execute the bulk update for the slice of sections
  puts ""
  puts "updating sections of courses #{course_ids[1]} through #{course_ids[-1]}. #{count} sections. #{total} so far."
  bulk.execute unless count == 0
end