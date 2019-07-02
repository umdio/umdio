# This pulls GIS data from this GitHub Repo, originally from zfogg
# https://gist.githubusercontent.com/McIntireEvan/34f7875ad0e302cbba8615f60460cdcb/raw/b177299262f53246c7404bbb1d2c2800dd1006c2/umd-building-gis.json
# TODO: Find a UMD source to pull this data from, rather than manual updates

require 'open-uri'
require 'net/http'
require 'mongo'

require_relative 'scraper_common.rb'
require_relative '../models/building.rb'
include ScraperCommon

prog_name = "buildings"

logger = ScraperCommon::logger
buildings = buildings_table(DB)

url="https://gist.githubusercontent.com/McIntireEvan/34f7875ad0e302cbba8615f60460cdcb/raw/b177299262f53246c7404bbb1d2c2800dd1006c2/umd-building-gis.json"

array = eval open(url).read
array.each do |e|
  buildings.insert(:name => e[:name], :code => e[:code], :id => e[:number].upcase, :long => e[:lng], :lat => e[:lat])
  logger.info(prog_name) {"inserted #{e[:name]}"}
end
