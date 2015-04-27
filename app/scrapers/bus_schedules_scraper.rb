# gets schedule information for bus routes
# run every ~month

require 'mongo'
require 'net/http'
require 'json'
include Mongo
include JSON

#set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port).db('umdbus')

# set up routes and schedules collections
routes_coll = db.collection('routes')
schedule_coll = db.collection('schedules')

routes = routes_coll.find({},{fields:{_id:0,route_id:1}}).map{|e| e['route_id']}.flatten
address = "http://webservices.nextbus.com/service/publicJSONFeed?a=umd&command=schedule"
routes.each do |route|
  page = JSON.parse(Net::HTTP.get(URI(address + "&r=#{route}")))
  
  schedules = []
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
    schedules << {
        days: days,
        direction: direction,
        schedule_class: schedule_class,
        stops: stops,
        trips: trips
      }
  end
  puts "updating the schedule for route #{route}"
  schedule_coll.update({route: route}, {'$set' => {
    route: route,
    schedules: schedules
  }}, {upsert: true})
end