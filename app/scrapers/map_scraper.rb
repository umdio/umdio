# This pulls GIS data from this GitHub Repo, originally from zfogg
# https://raw.githubusercontent.com/umdio/umdio-data/master/umd-building-gis.json
# TODO: Find a UMD source to pull this data from, rather than manual updates

require 'open-uri'
require 'net/http'
require 'csv'

require_relative 'scraper_common'
require_relative '../models/building'

# Number of buildings to query at a time from Facilities ArcGIS database
BLDG_QUERY_SIZE = 100

class MapScraper
  include ScraperCommon

  ##
  #
  # @param [String, Integer, Array<String>, Array<Integer>] object_ids
  #
  # @return [Array<Hash>] list of buildings
  #
  # @see ArcGIS Layer Query Docs:https://developers.arcgis.com/rest/services-reference/enterprise/query-map-service-layer-.htm
  # @see Table HTML view: https://maps.umd.edu/arcgis/rest/services/Layers/CampusMapDefault/MapServer/9
  #
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

  ##
  # Parses a full Facilities Report CSV
  def parse_report
    quote_chars = %w[" | ~ ^ & *]
    report_csv = './data/umdio-data/facilities/FacilitiesReport-533.csv'

    begin
      report = CSV.read(report_csv, headers: :first_row, quote_char: quote_chars.shift)
    rescue CSV::MalformedCSVError
      quote_chars.empty? ? raise : retry
    end

    report
  end

  def scrape
    $DB[:buildings].delete
    # $DB.drop_table? :buildings

    idx = 0
    done = false
    bldg_data = []
    bar = get_progress_bar total: nil, format: '%t: |%B| (%c - %a)'

    until done
      buildings = facilities_location_data (idx..(idx + BLDG_QUERY_SIZE)).to_a
      done = buildings.empty?

      next if done

      log(bar, :debug) { `Inserting building #{bldg}` }
      buildings.each do |bldg|
        $DB[:buildings].insert_ignore.insert(**bldg)
        bar.increment
      end

      idx += BLDG_QUERY_SIZE

    end

    bar.finish
  end
end

MapScraper.new.run_scraper if $PROGRAM_NAME == __FILE__
