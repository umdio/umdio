# adds start_seconds and end_seconds 

require 'mongo'
include Mongo
require_relative '../helpers/courses_helpers.rb'
include Sinatra::UMDIO::Helpers

# set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
db = MongoClient.new(host, port, pool_size: 2, pool_timeout: 2).db('umdclass')

sections_names = db.collection_names().select { |x| x.start_with? 'sections' }

sections_names.each do |coll|
  sections = db.collection(coll) 
  bulk = sections.initialize_ordered_bulk_op()
  sections.find().each do |section|
    meetings = section['meetings']
    meetings.each_with_index do |e, i|
      meetings[i]['start_seconds'] = time_to_int(e['start_time'])
      meetings[i]['end_seconds'] = time_to_int(e['end_time'])
    end
    bulk.find({'_id' => section['_id']}).update_one( { '$set' => { 'meetings' => meetings } } )
  end
  bulk.execute() rescue nil
end
