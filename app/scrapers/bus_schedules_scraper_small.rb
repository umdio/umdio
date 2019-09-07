# version of schedule scraper that makes smaller schedules for route/day/direction
# gets schedule information for bus routes
# run every ~month

require 'net/http'
require 'json'
include JSON
require_relative 'scraper_common.rb'
include ScraperCommon

require_relative '../models/bus.rb'

prog_name = "bus_schedules_scraper"

logger = ScraperCommon::logger

routes = Route.all.map {|r| r.route_id}
address = "http://webservices.nextbus.com/service/publicJSONFeed?a=umd&command=schedule"
routes.each do |route|
  begin
    page = JSON.parse(Net::HTTP.get(URI(address + "&r=#{route}")))
  rescue JSON::ParserError
    logger.info(prog_name) { "Retrying..."}
    retry
  end
  next if !(page['route'])
  sch = page['route']
  sch.each do |service|
    days = service['serviceClass']
    direction = service['direction']
    schedule_class = service['scheduleClass']
    stops = []
    header = service['header']
    if header['stop'].is_a?(Array)
      header['stop'].each do |stop|
        stops << {stop_id: stop['tag'], name: stop['content']}
      end
    else
      stops << {stop_id: header['stop']['tag'], name: header['stop']['content']}
    end
    trips = []
    trs = service['tr']
    trs.each do |trip|
      stop_times = []
      if trip['stop'].is_a?(Array)
        trip['stop'].each do |stop|
          stop_times << {
            stop_id: stop['tag'],
            arrival_time: stop['content'],
            arrival_time_secs: stop['epochTime']
          }
        end
      else
        stop_times << {stop_id: trip['stop']['tag'], arrival_time: trip['stop']['content'], arrival_time_secs: trip['stop']['epochTime']}
      end
      trips << stop_times
    end
    logger.info(prog_name) {"updating the #{days} schedule for route #{route} in the #{direction} direction"}
    $DB[:schedules].insert_ignore.insert(
      :route => route,
      :days => days,
      :direction => direction,
      :schedule_class => schedule_class,
      :stops => Sequel.pg_jsonb_wrap(stops),
      :trips => Sequel.pg_jsonb_wrap(trips)
    )
  end
end