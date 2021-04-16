require 'open-uri'
require 'nokogiri'

require_relative 'scraper_common.rb'
include ScraperCommon

require_relative '../models/majors.rb'

prog_name = "majors_scraper"

logger = ScraperCommon::logger

url = "https://admissions.umd.edu/explore/colleges-and-schools/majors/majors-alphabetically"
page = ScraperCommon::page_url url, prog_name
major_divs = page.css(".page--inner-content a")
majors = []
major_divs.each do |link|
  # parse the name to grab the major's name and its college

  major_url = link['href']
  next unless major_url and major_url.include? 'umd.edu'
  major_parts = /(.+)\|(.+)/.match(link.text)

  if major_parts != nil
    # 0th match is full string, 1st and 2nd elements are the two matches
    major_name, major_college = major_parts[1, 3].map(&:strip)

    majors << {
      name: major_name,
      college: major_college,
      url: major_url
    }
  end
end

$DB[:majors].delete
majors.each do |major|
  logger.info(prog_name) { "inserting #{major[:name]}"}

  major[:major_id] = major[:name].upcase.gsub!(/[^0-9A-Za-z]/, '')
  major[:major_id] = major[:name].upcase if major[:major_id] == nil
  $DB[:majors].insert_ignore.insert(:major_id => major[:major_id], :name => major[:name], :college => major[:college], :url => major[:url])
end
logger.info(prog_name) {"Inserted #{majors.length} majors"}
