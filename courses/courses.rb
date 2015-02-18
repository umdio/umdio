#Module for the courses endpoint is defined. Relies on helpers in courses_helpers.rb

#logic for the courses api
          #Available endpoints:
          #/courses/sections/:section_id   => get a particular section of a course, or more than one, comma separated
          #/courses/sections              => Currently does not do anything useful
          #/courses/list                  => lists courses
          #/courses/search                => fuzzy search through course database
          #/courses                       => lists courses

module Sinatra
  module UMDIO
    module Routing
      module Courses

        def self.registered(app)

          #set the collections by accessing the db variable we attached to the app's settings
          course_coll = app.settings.db.collection('courses')
          section_coll = app.settings.db.collection('sections')

          #Returns sections of courses by their id
          app.get '/v0/courses/sections/:section_id' do
            #TODO: need meaningful bad results, sanitize queries (turn + into ,)
            #get the parameters
            query = "#{params[:section_id]}"
            #separate into an array on commas, turn it into uppercase for the database (should be in the sanitization)
            section_ids = query.upcase.split(",")
            json find_sections section_ids, section_coll #using helper method
          end

          #should this give error or it could do something like courses/list except with sections array too?
          app.get '/v0/courses/sections' do
            #TODO does this really exist? What do we return on this?
            "We still don't know what should be returned here. Do you?"
          end

          # Returns unordered list of all courses, with the department, course code, and name
          app.get '/v0/courses/list' do
            json find_all_courses course_coll
          end

          #Returns section info about particular sections of a course, comma separated
          app.get '/v0/courses/:course_id/sections/:section_id' do
            course = "#{params[:course_id]}" # needs further sanitization
            section_numbers = "#{params[:section_id]}".upcase.split(',') #still more sanitization to do
            section_ids = section_numbers.map {|number| "#{course}-#{number}"}
            json find_sections section_ids, section_coll
          end

          #Returns section objects of a given course
          app.get '/v0/courses/:course_id/sections' do
            query = "#{params[:course_id]}" # needs further sanitization
            course = course_coll.find({course_id: query},{fields:{_id:0, 'sections._id' => 0}}).to_a
            section_ids = course[0]['sections'].map { |e| e['section_id'] }
            json find_sections section_ids,section_coll
          end

          # returns courses specified by :course_id
          # MAYBE     if a section_id is specified, returns sections info as well
          # MAYBE     if only a department is specified, acts as a shortcut to search with ?dep=<param>
          app.get '/v0/courses/:course_id' do
            #need to sanitize, return meaningful errors (such as on mixed queries)

            query = "#{params[:course_id]}"
            course_ids = query.upcase.split(',') #capitalizes, splits into array
            if course_ids.length > 1
              courses = course_coll.find({course_id: { '$in' => course_ids}},{fields:{_id:0, 'sections._id' => 0}}).to_a
              courses.each{|course| course['sections'] = flatten_sections course['sections']}
            else
              courses = course_coll.find({course_id: course_ids[0]},{fields:{_id:0, 'sections._id' => 0}}).to_a
              courses.each{|course| course['sections'] = flatten_sections course['sections']}
              courses = courses[0] #to get rid of [] on single object return
            end
            json courses
          end

          #returns a list of courses, just like /courses/list
          #do we need to put a limit on here? How do we do pagination/default limiting?
          app.get '/v0/courses' do
            json find_all_courses course_coll
          end
           
        end

      end
    end
  end
end
