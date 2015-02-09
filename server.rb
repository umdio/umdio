require 'sinatra'
require 'sinatra/reloader'
require 'mongo'
require 'json/ext' # required for .to_json

include Mongo

#set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

#announce connection and connect
puts "Connecting to mongo on #{host}:#{port}"
db = MongoClient.new(host, port).db('umdclass')

#set the courses collection
courses = db.collection('courses')

#set a variable for displaying the names of the databases
collections = db.collection_names
collections.delete('system.indexes')

status = 'Broken'

#logic for the courses api
#Available endpoints:
  #/courses/sections/:sectionid   => get a particular section of a course, or more than one, comma separated
  #/courses/sections              => DOES THIS DO ANYTHING????
  #/courses/list                  => lists courses
  #/courses/search                => fuzzy search through course database
  #/courses                       => can specify a whole course, or just 

  
  #returns sections of courses by their id
get '/api/courses/sections/:sectionid' do
  #TODO - needs to return by multiple section ids
  #need to fix database side first
  "You are searching by section for #{params[:sectionid]}"
end

  #This might not actually be a real endpoint, it might error out
get '/api/courses/sections' do
  #TODO does this really exist? What do we return on this?
end

  # returns unordered list of all courses
  # gives the department, course code, and name for each course
get '/api/courses/list' do
  courses.find({},{:fields =>{:_id => 0, :department => 1, :code => 1, :name => 1}}).to_a.to_json
end

get '/api/courses/:courseid/sections/:sectionid' do
  "We ain't built /courses/:courseid/sections/:sectionid yet. <br>
  But I know that you're asking for section #{params[:sectionid]} of course #{course(params[:courseid])}"
end

get '/api/courses/:courseid/sections' do
  "Oh, you're looking for the sections for #{course(params[:courseid])}? <br>We haven't got any of those. Yet."
end

  # returns courses specified by :courseid
  # 
get '/api/courses/?:courseid' do
  "The department is: #{dep(params[:courseid])} <br>
  The course is: #{course(params[:courseid])} <br>
  The section is: #{section(params[:courseid])}"
end

get '/api/courses' do
  "End of the line, punk. <br> We ain't implemented /api/courses yet."
  #courses.find(params).to_a.to_json
  # courses.find({},{:fields =>{:_id => 0, :department => 1, :code => 1, :name => 1} }).to_a.to_json
end

get '/*' do  
  path = params[:splat].first
  "This is the home of the umd.io JSON api. (currently #{status}) <br>
  You got here from: #{if(path.length > 0) then path + ", which isn't seem to be a real place yet." else "/" end} <br>
  We'll tell you more about the available endpoints when there are real docs!<br>
  Available collections: <br>
  #{collections}
  "
end

#helper method to capture relevant parts of a string
def pattern_match string
  #this is a complicated-looking pattern. It matches strings like enes100, enes, Enes100 ENES, ENGL398b, and ENES100-0101.
  #capture groups are as follows: 1 - full course code, 2 - dep code, 3 - course number, 4 - unused letter specifier, 5 - section number
  #we'll still need to sanitize them, because the database doesn't like
  pattern = /(([a-zA-Z]{4})(\d{3}([a-zA-Z])?)?)-?(\d{4})?/
  pattern.match(string)
end

#returns the course code from a string
def course string
  match = pattern_match string
  if match and match[3] then match[1] else nil end
end

#returns department code from a string
def dep string  
  match = pattern_match string
  if match then match[2] else nil end
end

#returns section number from a string
def section string
  match = pattern_match string
  if match then match[-1] else nil end
end
