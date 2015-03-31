# Module for the courses endpoint is defined. Relies on helpers in courses_helpers.rb

module Sinatra
  module UMDIO
    module Routing
      module Courses

        def self.registered(app)

          # set the collections by accessing the db variable we attached to the app's settings
          course_coll = app.settings.db.collection('courses')
          section_coll = app.settings.db.collection('sections')
          bad_url_message = {error_code: 400, message: "Check your url! It doesn't seem to correspond to anything on the umd.io api. If you think it should, create an issue on our github page.", docs: "http://umd.io/docs/"}.to_json

          app.before do
            content_type 'application/json'
          end

          # Returns sections of courses by their id
          app.get '/v0/courses/sections/:section_id' do
            # separate into an array on commas, turn it into uppercase
            section_ids = "#{params[:section_id]}".upcase.split(",")
            section_ids.each {|section_id| halt 400, bad_url_message unless is_full_section_id? section_id}
            json find_sections section_ids, section_coll #using helper method
          end

          # should this give error or it could do something like courses/list except with sections array too?
          app.get '/v0/courses/sections' do
            # TODO does this really exist? What do we return on this?
            "We still don't know what should be returned here. Do you?"
          end

          # Returns unordered list of all courses, with the department, course code, and name
          app.get '/v0/courses/list' do
            json find_all_courses course_coll
          end

          # Returns section info about particular sections of a course, comma separated
          app.get '/v0/courses/:course_id/sections/:section_id' do
            course_id = "#{params[:course_id]}".upcase
            halt 400, bad_url_message unless is_course? course_id
            section_numbers = "#{params[:section_id]}".upcase.split(',')
            section_numbers.each { |number| halt 400, bad_url_message unless is_section? number }
            section_ids = section_numbers.map { |number| "#{course_id}-#{number}" }
            json find_sections section_ids, section_coll
          end

          # Returns section objects of a given course
          app.get '/v0/courses/:course_id/sections' do
            course_id = "#{params[:course_id]}".upcase
            halt 400, bad_url_message unless is_course? course_id
            course = course_coll.find({course_id: course_id},{fields:{_id:0, 'sections._id' => 0}}).to_a
            section_ids = course[0]['sections'].map { |e| e['section_id'] }
            json find_sections section_ids,section_coll
          end

          # returns courses specified by :course_id
          # MAYBE     if a section_id is specified, returns sections info as well
          # MAYBE     if only a department is specified, acts as a shortcut to search with ?dept=<param>
          app.get '/v0/courses/:course_id' do
            # parse params
            course_ids = "#{params[:course_id]}".upcase.split(',')
            course_ids.each { |id| halt 400, bad_url_message unless is_course? id }

            # query db
            if course_ids.length > 1
              courses = course_coll.find({course_id: { '$in' => course_ids}},{fields:{_id:0, 'sections._id' => 0}}).to_a
            else
              courses = course_coll.find({course_id: course_ids[0]},{fields:{_id:0, 'sections._id' => 0}}).to_a
            end

            # flatten sections
            section_ids = []
            courses.each do |course|
              course['sections'] = flatten_sections course['sections']
              section_ids.concat course['sections']
            end

            # expand sections if ?expand=sections
            if params[:expand] == 'sections'
              sections = find_sections section_ids, section_coll
              sections = [sections] if not sections.kind_of?(Array) # hacky, maybe modify find_sections?

              # map sections to course hash & replace section data
              course_sections = sections.group_by { |e| e['course'] }
              courses.each { |course| course['sections'] = course_sections[course['course_id']] }
            end

            # get rid of [] on single object return
            courses = courses[0] if course_ids.length == 1
            # prevent null being returned
            courses = {} if not courses

            json courses
          end

          # returns a list of courses, just like /courses/list
          app.get '/v0/courses' do
            courses = find_all_courses_full course_coll
            courses.each{|course| course['sections'] = flatten_sections course['sections']}
            json courses
          end

        end

      end
    end
  end
end
