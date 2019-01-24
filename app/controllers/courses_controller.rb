# Module for the courses endpoint is defined. Relies on helpers in courses_helpers.rb
module Sinatra
  module UMDIO
    module Routing
      module Courses
        def self.registered(app)
          app.before '/v0/courses*' do
            @special_params = ['sort', 'semester', 'expand', 'per_page', 'page']

            params[:semester] ||= current_semester
            check_semester app, params[:semester], 'courses'

            # TODO: This could be more concise
            if params['expand']
              params['expand'] = params['expand'].to_s == 'true'
            end

            @db = app.settings.postgres
          end

          # TODO: CONVERT
          # Returns sections of courses by their id
          app.get '/v0/courses/sections/:section_id' do
            # separate into an array on commas, turn it into uppercase
            section_ids = "#{params[:section_id]}".upcase.split(",")

            section_ids.each do |section_id|
              if not is_full_section_id? section_id
                halt 400, { error_code: 400, message: "Invalid section_id #{section_id}"}.to_json
              end
            end

            res = find_sections @db, (params[:semester] || current_semester), section_ids

            # If we only have 1 result, we have to just return it (for compatibility)
            # TODO (v1): Fix this
            if res.length == 1
              return json res[0]
            end

            json res
          end

          # TODO: CONVERT
          # TODO: allow for searching in meetings properties
          app.get '/v0/courses/sections' do
            semester = params[:semester] || current_semester

            begin_paginate! @db, "sections#{semester}"

            # get parse the search and sort
            sorting = params_sorting_array 'section_id'
            query   = params_search_query  @db, @special_params

            halt 404, ::JSON.generate(query)

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
            semesters = @db.exec('SELECT DISTINCT semester FROM courses;').values.flatten
            json semesters.sort
          end

          app.get '/v0/courses/departments' do
            departments = @db.exec('SELECT DISTINCT dept_id, department FROM courses;').values
            departments.sort_by! {|dept| dept[0] }
            json departments.map {|e| {'dept_id': e[0], 'department': e[1]}}
          end

          app.get '/v0/courses/list' do
            semester = params['semester'] || current_semester
            json (find_courses_in_sem @db, semester)
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
            sections = find_sections @db, (params[:semester] || current_semester), section_ids

            if sections.nil? or sections.empty?
              halt 404, { error_code: 404, message: "No sections found." }.to_json
            end

            json sections
          end

          # TODO: sort??
          # Returns section objects of a given course
          app.get '/v0/courses/:course_id/sections' do
            course_id = "#{params[:course_id]}".upcase
            json find_sections_for_course @db, (params[:semester] || current_semester), course_id, true
          end

          # returns courses specified by :course_id
          # MAYBE     if a section_id is specified, returns sections info as well
          # MAYBE     if only a department is specified, acts as a shortcut to search with ?dept=<param>
          app.get '/v0/courses/:course_id' do
            # parse params
            course_ids = "#{params[:course_id]}".upcase.split(',')

            courses = find_courses @db, (params[:semester] || current_semester), course_ids, params

            # TODO: get rid of this
            # get rid of [] on single object return
            courses = courses[0] if course_ids.length == 1
            # prevent null being returned
            courses = {} if not courses

            json courses
          end

          # returns a paginated list of courses, with the full course objects
          app.get '/v0/courses' do
            begin_paginate! @db, 'courses'

            # sanitize params
            # TODO: sanitize more parameters to make searching a little more user friendly
            params['dept_id'] = params['dept_id'].upcase if params['dept_id']

            # get parse the search and sort
            sorting = 'course_id ASC'#params_sorting_array 'course_id'
            query   = 'true' #params_search_query @db, @special_params
            offset = (@page - 1)*@limit
            limit = @limit

            res = @db.exec("SELECT * FROM courses WHERE #{query} ORDER BY #{sorting} LIMIT #{limit} OFFSET #{offset}")
            courses = []
            res.each do |row|
              courses << (clean_course @db, (params[:semester] || current_semester), row)
            end

            end_paginate! courses

            json courses
          end
        end
      end
    end
  end
end
