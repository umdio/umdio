# This pulls GIS data from this GitHub Repo, originally from zfogg
# https://raw.githubusercontent.com/umdio/umdio-data/master/umd-building-gis.json
# TODO: Find a UMD source to pull this data from, rather than manual updates

require 'open-uri'
require 'net/http'

require_relative 'scraper_common'

require_relative '../models/building'

# Number of buildings to query at a time from Facilities ArcGIS database
BLDG_QUERY_SIZE = 100

class MapScraper
  include ScraperCommon

  def url
    'https://raw.githubusercontent.com/umdio/umdio-data/master/umd-building-gis.json'
  end

  ##
  #
  # @param [String, Integer, Array<String>, Array<Integer>] object_ids
  # @return [Array<Hash>] list of buildings
  #
  # @see ArcGIS Layer Query Docs:https://developers.arcgis.com/rest/services-reference/enterprise/query-map-service-layer-.htm
  # @see Table HTML view: https://maps.umd.edu/arcgis/rest/services/Layers/CampusMapDefault/MapServer/9
  def facilities_location_data(object_ids)
    object_ids = object_ids.join(',') if object_ids.is_a? Array

    # https://developers.arcgis.com/rest/services-reference/enterprise/query-map-service-layer-.htm
    uri = URI("https://maps.umd.edu/arcgis/rest/services/Layers/CampusMapDefault/MapServer/9/query?objectIds=#{object_ids}&outFields=*&f=json")
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)
    buildings = data['features']

    raise TypeError, 'buildings is nil' if buildings.nil?
    raise TypeError, 'buildings is not an array' unless buildings.is_a? Array

    buildings.map { |bldg| clean_building_data(bldg['attributes']) }
  end

  ##
  #
  # @param [Hash] data an ArcGIS building feature object
  #
  # @return [Hash] `data`, but sanitized and formatted
  #
  def clean_building_data(data)
    raise ArgumentError, 'data param should be a hash' unless data.is_a? Hash

    {
      id: data['BLDGNUM'].to_i,
      code: data['BLDGCODE'],
      name: data['NAME'].split(' ')
                        .map(&:capitalize)
                        .join(' '),

      # Location data
      city: data['CITY'],
      state: data['STATE'],
      zip: data['ZIP'].to_i,
      long: data['LONGITUDE'].to_f,
      lat: data['LATITUDE'].to_f,

      # Street data
      street: data['STREET'],
      street_name: data['STREETNAME'],
      address_num: data['ADDRNUM']
      # street_type: data['_TYPE'],
      # street_rev_street: data['REV_STREET'],

      # Misc
      # prefix: data['PREFIX'], # not sure what this is, is usually nil
      # suffix: data['SUFFIX']  # not sure what this is, is usually nil
    }
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
    # $DB.drop_table? :buildings

    idx = 0
    done = false
    bldg_data = []

    until done
      buildings = facilities_location_data((idx..(idx + BLDG_QUERY_SIZE)).to_a)
      done = buildings.empty?

      next if done

      buildings.each do |bldg|
        $DB[:buildings].insert_ignore.insert(**bldg)
      end

      idx += BLDG_QUERY_SIZE

    end
  end
end

MapScraper.new.run_scraper if $PROGRAM_NAME == __FILE__
