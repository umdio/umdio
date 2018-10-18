# This pulls GIS data from this GitHub Repo, originally from zfogg
# https://gist.githubusercontent.com/McIntireEvan/34f7875ad0e302cbba8615f60460cdcb/raw/b177299262f53246c7404bbb1d2c2800dd1006c2/umd-building-gis.json
# TODO: Find a UMD source to pull this data from, rather than manual updates

require 'open-uri'
require 'net/http'
require 'mongo'

require_relative 'scraper_common.rb'
include ScraperCommon

prog_name = "buildings"

logger = ScraperCommon::logger
db = ScraperCommon::database 'umdmap'
buildings_coll = db.collection('buildings')

url="https://gist.githubusercontent.com/McIntireEvan/34f7875ad0e302cbba8615f60460cdcb/raw/b177299262f53246c7404bbb1d2c2800dd1006c2/umd-building-gis.json"

# drop buildings first
buildings_coll.remove()

array = eval open(url).read
array.each do |e|
  # try to add image url
  image_url = "https://www.facilities.umd.edu/Buildings/Pictures/Medium/#{e[:number]}.jpg"
  uri = URI(image_url)
  status = Net::HTTP.get_response(uri)
  unless status.kind_of? Net::HTTPNotFound
    e[:image_url] = image_url
  end

  e[:building_id] = e[:number].upcase
  e.delete :number
  buildings_coll.update({building_id: e[:building_id]}, {"$set" => e}, {upsert: true})

  logger.info(prog_name) {"inserted #{e[:name]}"}
end
