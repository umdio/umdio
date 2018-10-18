require 'open-uri'
require 'nokogiri'
require 'mongo'

require_relative 'scraper_common.rb'
include ScraperCommon

prog_name = "majors_scraper"

logger = ScraperCommon::logger
db = ScraperCommon::database 'umdmajors'
majors_coll = db.collection('majors')

majors_coll.remove()

url = "https://www.admissions.umd.edu/explore/majors"
page = Nokogiri::HTML(open(url))
major_divs = page.css("div.panel-body a")

majors = []
major_divs.each do |link|
  # parse the name to grab the major's name and its college
  major_parts = link.text.sub(')', '').split('(')
  major_name = major_parts[0].squeeze(' ')
  major_college = major_parts[1] ? major_parts[1].strip : ''

  # parse the url
  major_url = link['href']

  majors << {
    name: major_name,
    college: major_college,
    url: major_url
  }
end

majors.each do |major|
  logger.info(prog_name) { "inserting #{major[:name]}"}

  major[:major_id] = major[:name].upcase.gsub!(/[^0-9A-Za-z]/, '')
  majors_coll.update({ major_id: major[:major_id] }, { "$set" => major }, { upsert: true })
end
logger.info(prog_name) {"Inserted #{majors.length} majors"}
