# Script to link the sections to the courses. 
# Only run after courses and sections are scraped. 
# Can be run in parallel to the update open seats scraper

require 'mongo'
include Mongo

#set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

#announce connection and connect
puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port, pool_size: 2, pool_timeout: 2).db('umdclass')

course_collections = db.collection_names().select { |e| e.include?('courses') }.map { |name| db.collection(name) }

course_collections.each do |coll|
  bulk = coll.initialize_unordered_bulk_op
  matches = /courses(.+)/.match(coll.name)
  if not matches.nil?
    semester = matches[1]
    sect_coll = db.collection("sections#{semester}")
    courses = coll.find()
    courses.each do |course|
      sections = sect_coll.find({course: course['course_id']},{fields: {_id: 1, section_id: 1}}).to_a
      bulk.find({course_id: course['course_id']}).upsert().update({ "$set" => { sections: sections} })
    end
    puts "executing a batch insert for #{semester}"
    bulk.execute
  end
end
