# get umd building gis data from zfogg's github gist. Not really the ideal long-term solution...
# https://gist.githubusercontent.com/zfogg/4bc03d7f71d5f740d028/raw/afe9f0baeda4ef6a7a64d99fa14bded8eb6bf3a8/umd-building-gis.json

require 'open-uri'
require 'mongo'
include Mongo
#set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port).db('umdmap')
buildings_coll = db.collection('buildings')
buildings_coll.remove

url = "https://gist.githubusercontent.com/zfogg/4bc03d7f71d5f740d028/raw/afe9f0baeda4ef6a7a64d99fa14bded8eb6bf3a8/umd-building-gis.json"

array = eval open(url).read
array.each do |e|
  buildings_coll.insert(e)
  puts "inserted #{e[:name]}"
end