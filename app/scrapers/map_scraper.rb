# This pulls GIS data from this GitHub Repo, originally from zfogg
# https://raw.githubusercontent.com/umdio/umdio-data/master/umd-building-gis.json
# TODO: Find a UMD source to pull this data from, rather than manual updates

require 'open-uri'
require 'net/http'

require_relative 'scraper_common.rb'

require_relative '../models/building.rb'


class MapScraper
  include ScraperCommon

  def url
    'https://raw.githubusercontent.com/umdio/umdio-data/master/umd-building-gis.json'
  end

  def write_map_array(data)

    bar = get_progress_bar total: data.length
    data.each do |e|
      $DB[:buildings].insert_ignore.insert(name: e[:name], code: e[:code], id: e[:number].upcase, long: e[:lng], lat: e[:lat])
      log(bar, :debug) { "inserted #{e[:name]}" }
      bar.increment
    end
  end

  def scrape
    $DB[:buildings].delete

    uri = ARGF == 1 ? ARGV[0] : url
    array = eval URI.open(uri).read
    write_map_array(array)
  end
end

MapScraper.new.run_scraper if $PROGRAM_NAME == __FILE__
