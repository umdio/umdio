# Script to link the sections to the courses.
# Only run after courses and sections are scraped.
# Can be run in parallel to the update open seats scraper

require 'mongo'
include Mongo

# Connect to MongoDB, if no port specified it picks the default
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] ? ':' + ENV['MONGO_RUBY_DRIVER_PORT'] : ''

puts "Connecting to #{host}:#{port}"
db = Mongo::Client.new("mongodb://#{host}#{port}/umdclass")

course_collections = db.database.collection_names().select { |e| e.include?('courses') }.map { |name| db[name]}

course_collections.each do |coll|
  bulk = []
  matches = /courses(.+)/.match(coll.name)
  if not matches.nil?
    semester = matches[1]
    sect_coll = db["sections#{semester}"]
    courses = coll.find()
    courses.each do |course|
      sections = sect_coll.find({course: course['course_id']},{fields: {_id: 1, section_id: 1}}).to_a

      bulk << { :update_one => {
        :filter => { :course_id => course[:course_id] },
        :update => {'$set' => { :sections => sections } },
        :upsert => true
      }}
    end
    puts "executing a batch insert for #{semester}"
    coll.bulk_write(bulk, {:ordered => false})
  end
end