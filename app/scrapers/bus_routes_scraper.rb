# script for getting route info from nextbus api, dumping into Mongo database.
# run  every ~month

require 'net/http'
require 'json'
require 'set'

require_relative 'scraper_common'
require_relative '../models/bus'
require_relative 'lib/umo'

class BusRoutesScraper
  include ScraperCommon
  def scrape
    # apiRoot = 'http://webservices.nextbus.com/service/publicJSONFeed?a=umd'
    # address = apiRoot + '&command=routeList&t=0'
    # response_hash = JSON.parse(Net::HTTP.get(URI(address)).to_s)
    # route_array = response_hash['route'].map { |e| { route_id: e['tag'], title: e['title'] } }
    # bar = get_progress_bar total: route_array.length

    # @type [Array<Hash>]
    route_array = UMO.get_routes.map { |e| { route_id: e['tag'], title: e['title'], shortTitle: e['shortTitle'] } } 

    route_array&.each do |route|
      log(bar, :debug) { "getting #{route[:route_id]}" }
      address = apiRoot + "&command=routeConfig&r=#{route[:route_id]}"
      begin
        route_response = JSON.parse(Net::HTTP.get(URI(address)).to_s)['route']
      rescue JSON::ParserError
        log(bar, :warn) { 'Failed to parse JSON. Retrying...'}
        retry
      end
      stops = []
      next if route_response.nil?

      route_response['stop'].each do |stop|
        log(bar, :debug) { "inserting #{stop['title']}" }
        $DB[:stops].insert_ignore.insert(stop_id: stop['tag'], title: stop['title'], long: stop['lon'],
                                         lat: stop['lat'])
        stops << stop['tag']
      end

      paths = route_response['path'].map { |e| e['point'] }
      directions = [].push(route_response['direction']).flatten
      directions = directions.map do |e|
        {
          direction_id: e['tag'],
          title: e['title'],
          stops: e['stop'].map do |stop|
                   stop['tag']
          rescue StandardError
            e['stop']
                 end
        }
      end

      $DB[:routes].insert_ignore.insert(
        route_id: route[:route_id],
        title: route[:title],
        lat_max: route_response['latMax'],
        lat_min: route_response['latMin'],
        long_max: route_response['lonMax'],
        long_min: route_response['lonMin'],
        stops: Sequel.pg_jsonb_wrap(stops),
        directions: Sequel.pg_jsonb_wrap(directions),
        paths: Sequel.pg_jsonb_wrap(paths)
      )
      bar.increment
    end
  end
end

BusRoutesScraper.new.run_scraper if $PROGRAM_NAME == __FILE__
