# script for getting route info from nextbus api, dumping into Mongo database. 
# run  every ~month

require 'mongo'
require 'net/http'
require 'json'
require 'set'
include Mongo
include JSON

#set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port).db('umdbus')

# set up and clean the database collections
routes_coll = db.collection('routes')
stops_coll = db.collection('stops')

apiRoot = 'http://webservices.nextbus.com/service/publicJSONFeed?a=umd'
address = apiRoot + '&command=routeList'
response_hash = parse(Net::HTTP.get(URI(address)).to_s)
route_array = response_hash["route"].map { |e| {route_id: e["tag"], title: e["title"]} }
puts "Adding bus routes and stops to the database"
route_array.each do |route|
  puts "getting #{route[:route_id]}"
  address = apiRoot + "&command=routeConfig&r=#{route[:route_id]}"
  route_response = parse(Net::HTTP.get(URI(address)).to_s)["route"]
  stops = []
  route_response["stop"].each do |stop|
    puts "inserting #{stop["title"]}"
    stops_coll.update({stop_id: stop["stop_id"]},{ 
      "$set" =>
        {
          stop_id: stop["tag"],
          title: stop["title"],
          lon: stop["lon"],
          lat: stop["lat"]
        },
      "$addToSet" =>
        {
          routes: route[:route_id]
        }
    }, {upsert: true}) # update or insert stops to mongo
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

  routes_coll.update({route_id: route["route_id"]}, # match the route, if it exists
  { "$set" => {
    route_id: route[:route_id],
    title: route[:title],
    stops: stops,
    directions: directions,
    paths:  paths,
    lat_max: route_response["latMax"],
    lat_min: route_response["latMin"],
    lon_max: route_response["lonMax"],
    lon_min: route_response["lonMin"], 
  }}, {upsert: true}) # update or insert route
end