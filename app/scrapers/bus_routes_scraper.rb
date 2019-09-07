# script for getting route info from nextbus api, dumping into Mongo database.
# run  every ~month

require 'net/http'
require 'json'
require 'set'
include JSON

require_relative 'scraper_common.rb'
include ScraperCommon

require_relative '../models/bus.rb'

prog_name = "bus_routes_scraper"

logger = ScraperCommon::logger

apiRoot = 'http://webservices.nextbus.com/service/publicJSONFeed?a=umd'
address = apiRoot + '&command=routeList&t=0'
response_hash = parse(Net::HTTP.get(URI(address)).to_s)
route_array = response_hash["route"].map { |e| {route_id: e["tag"], title: e["title"]} }
logger.info(prog_name) {"Adding bus routes and stops to the database"}
unless route_array.nil?
  route_array.each do |route|
    logger.info(prog_name) {"getting #{route[:route_id]}"}
    address = apiRoot + "&command=routeConfig&r=#{route[:route_id]}"
    begin
      route_response = JSON.parse(Net::HTTP.get(URI(address)).to_s)["route"]
    rescue JSON::ParserError
      logger.info(prog_name) { "Retrying..."}
      retry
    end
    stops = []
    unless route_response.nil?
      route_response["stop"].each do |stop|
        logger.info(prog_name) {"inserting #{stop["title"]}"}
        $DB[:stops].insert_ignore.insert(:stop_id => stop["tag"], :title => stop["title"], :long => stop["lon"], :lat => stop["lat"])
        stops << stop["tag"]
      end

      paths = route_response["path"].map {|e| e["point"] }
      directions = [].push(route_response["direction"]).flatten
      directions = directions.map do |e|
        {
          direction_id: e["tag"],
          title: e["title"],
          stops: e["stop"].map{|stop| stop["tag"] rescue e["stop"]}
        }
      end

      $DB[:routes].insert_ignore.insert(
        :route_id => route[:route_id],
        :title => route[:title],
        :lat_max => route_response["latMax"],
        :lat_min => route_response["latMin"],
        :long_max => route_response["lonMax"],
        :long_min => route_response["lonMin"],
        :stops => Sequel.pg_jsonb_wrap(stops),
        :directions => Sequel.pg_jsonb_wrap(directions),
        :paths => Sequel.pg_jsonb_wrap(paths)
      )
    end
  end
end