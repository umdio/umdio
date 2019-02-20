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
              params['expand'] = params['expand'].to_s.downcase == 'sections'
            end

            @db = app.settings.postgres
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
            begin_paginate! @db, "sections"

            query = ''

            # TODO: This has a lot of overlap with params_search_query, but has to be separate specifically for querying the JSONB.

            # Properties that we have to search JSONB to find
            meeting_properties = ['days', 'start_time', 'end_time', 'building', 'room', 'classtype']
            prefixed_meeting_properties = ['meetings.days', 'meetings.start_time', 'meetings.end_time', 'meetings.building', 'meetings.room', 'meetings.classtype']

            params.keys.each do |key| if (meeting_properties + prefixed_meeting_properties).include? key.chomp('<').chomp('>').chomp('!')
              if key.include? 'meeting.'
                new_key = key.split('.')[1]
                params[new_key] = params[key]
                params.delete(key)
                key = new_key
              end

              delim = ''
              if key[-1] == '<'
                delim = '<'
              elsif key[-1] == '>'
                delim = '>'
              elsif key[-1] == '!'
                delim = '!'
              end

              n_key = key.chomp('<').chomp('>').chomp('!')

              if n_key == 'start_time'
                params['start_seconds'] = time_to_int(params['start_time'])
                params.delete('start_time')
              end

              if n_key == 'end_time'
                params['start_seconds'] = time_to_int(params['start_time'])
                params.delete('start_time')
              end

              query += " EXISTS(SELECT 1 from jsonb_array_elements(meetings) elem WHERE elem->>'#{n_key}'='#{params[key]}') AND "
            end
            end

            # get parse the search and sort
            sorting = params_sorting_array 'section_id'
            query  += params_search_query @db, (@special_params + meeting_properties)

            if query == ''
              query = 'TRUE'
            end

            offset = (@page - 1)*@limit
            limit = @limit

            query.chomp! "AND "

            res = @db.exec("SELECT * FROM sections WHERE #{query} LIMIT #{limit} OFFSET #{offset}")
            sections = []

            res.each do |row|
              sections << (clean_section @db, (params[:semester] || current_semester), row)
            end

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
            sorting = params_sorting_array
            query = params_search_query @db, @special_params
            offset = (@page - 1)*@limit
            limit = @limit

            if query == ''
              query = 'TRUE'
            end

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
