# frozen_string_literal: true

# This pulls GIS data from this GitHub Repo, originally from zfogg
# https://raw.githubusercontent.com/umdio/umdio-data/master/umd-building-gis.json
# TODO: Find a UMD source to pull this data from, rather than manual updates

require 'open-uri'
require 'net/http'

require_relative 'scraper_common'
include ScraperCommon

require_relative '../models/building'

$prog_name = 'buildings'

logger = ScraperCommon.logger
url = 'https://raw.githubusercontent.com/umdio/umdio-data/master/umd-building-gis.json'

def write_map_array(data)
  data.each do |e|
    $DB[:buildings].insert_ignore.insert(name: e[:name], code: e[:code], id: e[:number].upcase, long: e[:lng], lat: e[:lat])
    logger.info($prog_name) { "inserted #{e[:name]}" }
  end
end

$DB[:buildings].delete

uri = ARGF == 1 ? ARGV[0] : url
array = eval URI.open(uri).read
write_map_array(array)
