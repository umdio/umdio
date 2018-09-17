require 'open-uri'
require 'nokogiri'
require 'mongo'
include Mongo

#set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

# announce connection and connect
puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port).db('umdmajors')
majors_coll = db.collection('majors')

majors_coll.remove()

url = "https://www.admissions.umd.edu/explore/majors"
page = Nokogiri::HTML(open(url))
major_divs = page.css("div.panel-body > div")

majors = []
major_divs.each do |div|
  puts div
  # parse the name to grab the major's name and its college
  major_parts = div.text.sub(')', '').split('(')
  major_name = major_parts[0].squeeze(' ')
  major_college = major_parts[1] ? major_parts[1].strip : ''

  # parse the url
  major_url = div.css('a')[0]['href']

  majors << {
    name: major_name,
    college: major_college,
    url: major_url
  }
end

majors.each do |major|
  puts "inserting #{major[:name]}"

  major[:major_id] = major[:name].upcase.gsub!(/[^0-9A-Za-z]/, '')
  majors_coll.update({ major_id: major[:major_id] }, { "$set" => major }, { upsert: true })
end
puts "Inserted #{majors.length} majors"
