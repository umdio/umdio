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
major_divs = page.css("div[style='padding:0 0 3px 10px; line-height:17px;']")

majors = []
major_divs.each do |div|

  # parse the name to grab the major's name and its college
  major_parts = div.text.sub(')', '').split('(')
  # TODO: this is currently a hacky fix to major names ending in a strange space character I couldn't remove
  major_name = major_parts[0][0...-1]
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
