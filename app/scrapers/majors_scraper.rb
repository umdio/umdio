require 'open-uri'
require 'nokogiri'

require_relative 'scraper_common.rb'
include ScraperCommon

require_relative '../models/majors.rb'

prog_name = "majors_scraper"

logger = ScraperCommon::logger

url = "https://admissions.umd.edu/explore/colleges-and-schools/majors/majors-alphabetically"
page = Nokogiri::HTML(open(url))
major_divs = page.css(".page--inner-content a")
majors = []
major_divs.each do |link|
  # parse the name to grab the major's name and its college
  major_parts = /(.+)\((.+)\)/.match(link.text)
  if major_parts != nil then
    major_name = major_parts[1].rstrip #Removes trailing space.
    major_college = major_parts[2]
    major_url = link['href']

    majors << {
      name: major_name,
      college: major_college,
      url: major_url
    }
  end
end

majors.each do |major|
  logger.info(prog_name) { "inserting #{major[:name]}"}

  major[:major_id] = major[:name].upcase.gsub!(/[^0-9A-Za-z]/, '')
  Major.insert(:major_id => major[:major_id], :name => major[:name], :college => major[:college], :url => major[:url])
end
logger.info(prog_name) {"Inserted #{majors.length} majors"}
