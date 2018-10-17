# Script to link the sections to the courses.
# Only run after courses and sections are scraped.
# Can be run in parallel to the update open seats scraper

require 'mongo'

require_relative 'scraper_common.rb'
include ScraperCommon

prog_name = "section_course_linker"

logger = ScraperCommon::logger
db = ScraperCommon::database 'umdclass'

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
    logger.info(prog_name) {"executing a batch insert for #{semester}"}
    bulk.execute
  end
end
