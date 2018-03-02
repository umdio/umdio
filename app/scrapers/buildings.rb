# get umd building gis data from zfogg's github gist. Not really the ideal long-term solution...
# https://gist.githubusercontent.com/zfogg/4bc03d7f71d5f740d028/raw/afe9f0baeda4ef6a7a64d99fa14bded8eb6bf3a8/umd-building-gis.json

require 'open-uri'
require 'net/http'
require 'mongo'
include Mongo

# Connect to MongoDB, if no port specified it picks the default
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] ? ':' + ENV['MONGO_RUBY_DRIVER_PORT'] : ''

puts "Connecting to #{host}:#{port}"
db = Mongo::Client.new("mongodb://#{host}#{port}/umdmap")
buildings_coll = db["buildings"]

url = "https://gist.githubusercontent.com/zfogg/4bc03d7f71d5f740d028/raw/afe9f0baeda4ef6a7a64d99fa14bded8eb6bf3a8/umd-building-gis.json"

# drop buildings first
buildings_coll.drop()

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
  buildings_coll.update_one({building_id: e[:building_id]}, {"$set" => e}, {upsert: true})

  puts "inserted #{e[:name]}"
end
