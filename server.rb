require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json' # are both needed?
require 'mongo'
require 'json/ext' # required for .to_json

include Mongo

#set up mongo database - code from ruby mongo driver tutorial
host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

#TODO: test driven development

#announce connection and connect
puts "Connecting to mongo on #{host}:#{port}"
db = MongoClient.new(host, port).db('umdclass')

#set the collections
courses = db.collection('courses')
sections = db.collection('sections')

#set a variable for displaying the names of the databases
collections = db.collection_names
collections.delete('system.indexes')

status = 'kinda working'

#logic for the courses api
#Available endpoints:
#/courses/sections/:section_id   => get a particular section of a course, or more than one, comma separated
#/courses/sections              => DOES THIS DO ANYTHING????
#/courses/list                  => lists courses
#/courses/search                => fuzzy search through course database
#/courses                       => 

#Returns sections of courses by their id
get '/api/courses/sections/:section_id' do
  #TODO: need meaningful bad results, sanitize queries (turn + into ,)
  #get the parameters
  query = "#{params[:section_id]}" 
  #separate into an array on commas, turn it into uppercase for the database (should be in the sanitization)
  section_ids = query.upcase.split(",") 
  json_sections section_ids, sections
end

#This might not actually be a real endpoint, it might error out
#or it could do something like courses/list except with sections array too
get '/api/courses/sections' do
  #TODO does this really exist? What do we return on this?
  "We still don't know what should be returned here. Do you?"
end

# Returns unordered list of all courses, with the department, course code, and name
get '/api/courses/list' do
  list_all_courses courses
end

#Returns section info about particular sections of a course, comma separated
get '/api/courses/:course_id/sections/:section_id' do
  course = "#{params[:course_id]}" # needs further sanitization
  section_numbers = "#{params[:section_id]}".upcase.split(',') #still more sanitization to do
  section_ids = section_numbers.map {|number| "#{course}-#{number}"}
  json_sections section_ids, sections
end

#Returns section objects of a given course
get '/api/courses/:course_id/sections' do
  query = "#{params[:course_id]}" # needs further sanitization
  course = courses.find({course_id: query},{fields:{_id:0, 'sections._id' => 0}}).to_a
  section_ids = course[0]['sections'].map { |e| e['section_id'] }
  json_sections section_ids,sections
end

# returns courses specified by :course_id
# MAYBE     if a section_id is specified, returns sections info as well
# MAYBE     if only a department is specified, acts as a shortcut to search with ?dep=<param>
get '/api/courses/:course_id' do
  #need to sanitize, return meaningful errors
  #squash sections? right now, sections: [{section_id:id},{section_id:id},{section_id:id}] 
  #--> we have the code to do this: sections_array.map { |e| e['section_id'] }
  #what do we do when we get /enes100,enes ?? (mixed search and explicit named sections)

  query = "#{params[:course_id]}"
  course_ids = query.upcase.split(',') #capitalizes, splits into array
  if course_ids.length > 1
    json courses.find({course_id: { '$in' => course_ids}},{fields:{_id:0, 'sections._id' => 0}}).to_a
  else
    json courses.find({course_id: course_ids[0]},{fields:{_id:0, 'sections._id' => 0}}).to_a[0]
  end
end

#returns a list of courses
get '/api/courses' do
  #do we need to put a limit on here? How do we do pagination/default limiting?
  list_all_courses courses
end

#base url, returns a list of available endpoints
get '/' do
  "This is the umd.io JSON api. (currently #{status}) <br>
  We'll tell you more about the available endpoints when there are real docs!<br>
  Available collections: <br>
  #{collections}
  "
end


get '/*' do
#should actually give a JSON formatted error
  path = params[:splat].first
  "You lost? <br>
  You came from #{if(path.length > 0) then path + ", which doesn't seem to be a real place yet." else "/" end} <br>
  You should get a map.
  "
end


##########    Helper Methods
####    When do these actually get used?

#helper method for printing json-formatted sections based on a sections collection and a list of section_ids
def json_sections section_ids, sections
  if section_ids.length > 1
    json sections.find({section_id: { '$in' => section_ids } },{fields: {_id: 0}}).to_a
  else
    json sections.find({section_id: section_ids[0]}, {fields: {_id: 0}}).to_a[0] # question about whether to remove brackets or not
  end
end

def list_all_courses courses
  json courses.find({},{:fields =>{:_id => 0, :department => 1, :course_id => 1, :name => 1}}).to_a #should be a lambda
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
