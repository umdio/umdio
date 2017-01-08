# Module for the courses endpoint is defined. Relies on helpers in courses_helpers.rb

module Sinatra
  module UMDIO
    module Routing
      module Courses
        
        def self.registered(app)

          app.before '/v0/courses*' do
            @special_params = ['sort', 'semester', 'expand', 'per_page', 'page']

            # TODO: don't hard code the current semester
            params[:semester] ||= '201608'

            # check for semester formatting
            if not (params[:semester].length == 6 and params[:semester].is_number?)
              halt 400, { error_code: 400, message: "Invalid semester parameter! semester must be 6 digits" }.to_json
            end

            # check if we have data for the requested semester
            collection_names = app.settings.courses_db.collection_names()
            if not collection_names.index("courses#{params[:semester]}")
              semesters = collection_names.select { |e| e.start_with? "courses" }.map{ |e| e.slice(7,6) }
              msg = "We don't have data for this semester! If you leave off the semester parameter, we'll give you the courses currently on Testudo. Or try one of the available semester below:"
              halt 404, {error_code: 404, message: msg, semesters: semesters}.to_json
            end

            @course_coll = app.settings.courses_db.collection("courses#{params[:semester]}")
            @section_coll = app.settings.courses_db.collection("sections#{params[:semester]}")
          end

          # Returns sections of courses by their id
          app.get '/v0/courses/sections/:section_id' do
            # separate into an array on commas, turn it into uppercase
            section_ids = "#{params[:section_id]}".upcase.split(",")

            section_ids.each do |section_id|
              if not is_full_section_id? section_id
                halt 400, { error_code: 400, message: "Invalid section_id #{section_id}"}.to_json
              end
            end

            json find_sections @section_coll, section_ids #using helper method
          end

          # TODO: allow for searching in meetings properties
          app.get '/v0/courses/sections' do
            begin_paginate! @section_coll

            # get parse the search and sort
            sorting = params_sorting_array 'section_id'
            query   = params_search_query  @special_params

            # adjust query if meeting property is specified without meetings qualifier
            meeting_properties = ['days', 'start_time', 'end_time', 'building', 'room', 'classtype']
            (query.keys & meeting_properties).each do |prop|
              query["meetings.#{prop}"] = query[prop]
              query.delete(prop)
            end

            # TODO: possible combine this with above / move into a helper method
            mappings = {'start_time' => 'start_seconds', 'end_time' => 'end_seconds'}
            mappings.each do |key, value|
              if query["meetings.#{key}"]
                val = query["meetings.#{key}"]
                if val.is_a? Hash
                  val.each { |k,v| val[k] = time_to_int(v) }
                  query["meetings.#{value}"] = val
                else
                  query["meetings.#{value}"] = time_to_int(val)
                end
                query.delete("meetings.#{key}")
              end
            end

            # map sorting parameters to their mongo-matching representation
            sorting.map! { |e| mappings.has_key?(e) ? "meetings.#{mappings[e]}" : e }

            sections = @section_coll.find(query, {:sort => sorting, :limit => @limit, :skip => (@page - 1)*@limit, :fields => {:_id => 0, 'meetings.start_seconds' => 0, 'meetings.end_seconds' => 0}}).map{ |e| e }

            end_paginate! sections

            json sections
          end

          # all of the semesters that we have
          app.get '/v0/courses/semesters' do
            collection_names = app.settings.courses_db.collection_names()
            semesters = collection_names.select { |e| e.start_with? "courses" }.map{ |e| e.slice(7,6) }
            json semesters
          end

          app.get '/v0/courses/departments' do
            departments = @course_coll.aggregate([
              {'$group' => { '_id' => { dept_id: "$dept_id", department: "$department" }}},
              {'$sort' => {'_id.dept_id': 1}}
            ])
            departments = departments.map{ |e| e }
            json departments.map { |e| e['_id'] }
          end

          app.get '/v0/courses/list' do
            courses = @course_coll.find({}, {:sort => ['course_id', 1], :fields =>{:_id => 0, :department => 1, :course_id => 1, :name => 1}}).map{ |e| e }
            json courses
          end

          # Returns section info about particular sections of a course, comma separated
          app.get '/v0/courses/:course_id/sections/:section_id' do
            course_id = "#{params[:course_id]}".upcase

            validate_course_ids course_id

            section_numbers = "#{params[:section_id]}".upcase.split(',')
            # TODO: validate_section_ids
            section_numbers.each do |number|
              if not is_section_number? number
                halt 400, { error_code: 400, message: "Invalid section_number #{number}" }.to_json
              end
            end

            section_ids = section_numbers.map { |number| "#{course_id}-#{number}" }
            sections = find_sections @section_coll, section_ids

            if sections.nil? or sections.empty?
              halt 404, { error_code: 404, message: "No sections found." }.to_json
            end

            json sections
          end

          # Returns section objects of a given course
          app.get '/v0/courses/:course_id/sections' do
            course_id = "#{params[:course_id]}".upcase

            courses = find_courses @course_coll, course_id
            section_ids = flatten_sections courses[0]['sections']

            json find_sections @section_coll, section_ids
          end

          # returns courses specified by :course_id
          # MAYBE     if a section_id is specified, returns sections info as well
          # MAYBE     if only a department is specified, acts as a shortcut to search with ?dept=<param>
          app.get '/v0/courses/:course_id' do
            # parse params
            course_ids = "#{params[:course_id]}".upcase.split(',')

            courses = find_courses @course_coll, course_ids

            courses = flatten_course_sections_expand @section_coll, courses

            # get rid of [] on single object return
            courses = courses[0] if course_ids.length == 1
            # prevent null being returned
            courses = {} if not courses

            json courses
          end

          # returns a paginated list of courses, with the full course objects
          app.get '/v0/courses' do
            begin_paginate! @course_coll

            # sanitize params
            # TODO: sanitize more parameters to make searching a little more user friendly
            params['dept_id'] = params['dept_id'].upcase if params['dept_id']

            # get parse the search and sort
            sorting = params_sorting_array 'course_id'
            query   = params_search_query  @special_params

            courses = @course_coll.find(query, {:sort => sorting, :limit => @limit, :skip => (@page - 1)*@limit, :fields => {:_id => 0}}).map{ |e| e }
            courses = flatten_course_sections_expand @section_coll, courses unless courses.empty?

            end_paginate! courses

            json courses
          end

        end

      end
    end
  end
end
