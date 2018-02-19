# This pulls GIS data from this GitHub Repo, originally from zfogg
# https://raw.githubusercontent.com/umdio/umdio/master/app/data/umd-building-gis.json
# TODO: Find a UMD source to pull this data from, rather than manual updates

require 'open-uri'
require 'net/http'
require 'mongo'
include Mongo
#set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port).db('umdmap')
buildings_coll = db.collection('buildings')

url="https://raw.githubusercontent.com/umdio/umdio/master/app/data/umd-building-gis.json"

# drop buildings first
buildings_coll.remove()

array = eval open(url).read
array.each do |e|
  # try to add image url
  image_url = "https://www.facilities.umd.edu/Buildings/Pictures/Medium/#{e[:number]}.jpg"
  uri = URI(image_url)
  status = Net::HTTP.get_response(uri)
  unless status.kind_of? Net::HTTPNotFound
    e[:image_url] = image_url
  end

  e[:building_id] = e[:number].upcase
  e.delete :number
  buildings_coll.update({building_id: e[:building_id]}, {"$set" => e}, {upsert: true})

  puts "inserted #{e[:name]}"
end
