# Module for the courses endpoint is defined. Relies on helpers in courses_helpers.rb
module Sinatra
  module UMDIO
    module Routing
      module Courses
        def self.registered(app)
          app.before '/v0/courses*' do
            @course_params = ['semester', 'course_id', 'credits', 'dept_id', 'grading_method', 'core', 'gen_ed', 'name']
            @section_params = []

            if !request.params['semester'] or (request.params['semester'] == '')
              request.update_param('semester', current_semester)
            end
            check_semester app, request.params['semester']

            # TODO: This could be more concise
            if request.params['expand']
              request.params('expand', request.params['expand'].to_s.downcase == 'sections')
            end
          end

          # Returns sections of courses by their id
          app.get '/v0/courses/sections/:section_id' do
            # separate into an array on commas, turn it into uppercase
            section_ids = "#{request.params[:section_id]}".upcase.split(",")

            section_ids.each do |section_id|
              if not is_full_section_id? section_id
                halt 400, { error_code: 400, message: "Invalid section_id #{section_id}"}.to_json
              end
            end

            res = find_sections (request.params['semester']), section_ids

            # If we only have 1 result, we have to just return it (for compatibility)
            # TODO (v1): Fix this
            if res.length == 1
              return json res[0]
            end

            json res
          end

          app.get '/v0/courses/sections' do
            begin_paginate! $DB[:sections]

            meeting_properties = ['days', 'start_time', 'end_time', 'building', 'room', 'classtype']

            request.params.keys.each do |key|
              nkey, delim, value, split = parse_param key, request.params[key]

              next unless (meeting_properties).include? nkey

              request.params.delete(key)

              if nkey == 'start_time'
                nkey = 'start_seconds'
                value = time_to_int(value)
              elsif nkey == 'end_time'
                nkey = 'end_seconds'
                value = time_to_int(value)
              end

              # TODO: More consice
              if nkey == 'start_time' or nkey == 'end_time'
                query += " EXISTS(SELECT 1 from jsonb_array_elements(meetings) elem WHERE (elem->>'#{nkey}')::int #{delim} #{value}) AND "
              else
                query += " EXISTS(SELECT 1 from jsonb_array_elements(meetings) elem WHERE elem->>'#{nkey}' #{delim} '#{value}') AND "
              end
            end

            # get parse the search and sort
            sorting = request.params_sorting_array 'section_id'
            query  += request.params_search_query @db, (@special_request.params + meeting_properties)

            if query == ''
              query = 'TRUE'
            end

            offset = (@page - 1)*@limit
            limit = @limit

            query.chomp! "AND "

            res = @db.exec("SELECT * FROM sections WHERE semester=#{semester} AND #{query} LIMIT #{limit} OFFSET #{offset}")
            sections = []

            res.each do |row|
              sections << (clean_section @db, semester, row)
            end

            end_paginate! sections

            json sections
          end

          # all of the semesters that we have
          app.get '/v0/courses/semesters' do
            json Course.distinct(:semester).map {|c| c[:semester]}.sort
          end

          app.get '/v0/courses/departments' do
            json Course.distinct(:dept_id, :department).map {|c| {dept_id: c[:dept_id], department: c[:department]}}.sort_by! {|d| d[:dept_id]}
          end

          app.get '/v0/courses/list' do
            json (find_courses_in_sem semester)
          end

          # Returns section info about particular sections of a course, comma separated
          app.get '/v0/courses/:course_id/sections/:section_id' do
            course_id = "#{request.params[:course_id]}".upcase

            validate_course_ids course_id

            section_numbers = "#{request.params[:section_id]}".upcase.split(',')
            # TODO: validate_section_ids
            section_numbers.each do |number|
              if not is_section_number? number
                halt 400, { error_code: 400, message: "Invalid section_number #{number}" }.to_json
              end
            end

            section_ids = section_numbers.map { |number| "#{course_id}-#{number}" }
            sections = find_sections request.params['semester'], section_ids

            if sections.nil? or sections.empty?
              halt 404, { error_code: 404, message: "No sections found." }.to_json
            end

            json sections
          end

          # TODO: sort??
          # Returns section objects of a given course
          app.get '/v0/courses/:course_id/sections' do
            course_id = request.params[:course_id].upcase
            res = find_sections_for_course request.params['semester'], course_id, true

            if res.empty?
              halt 404, {
                error_code: 404,
                message: "Course with course_id #{course_id} not found!",
                available_courses: "https://api.umd.io/v0/courses",
                docs: "https://umd.io/courses/"
              }.to_json
            end

            json res
          end

          # returns courses specified by :course_id
          # MAYBE     if a section_id is specified, returns sections info as well
          # MAYBE     if only a department is specified, acts as a shortcut to search with ?dept=<param>
          app.get '/v0/courses/:course_id' do
            # parse request.params
            course_ids = "#{request.params[:course_id]}".upcase.split(',')

            courses = find_courses request.params['semester'], course_ids, request.params

            # TODO: get rid of this
            # get rid of [] on single object return
            courses = courses[0] if course_ids.length == 1
            # prevent null being returned
            courses = {} if not courses

            json courses
          end

          # returns a paginated list of courses, with the full course objects
          app.get '/v0/courses' do
            begin_paginate! $DB[:courses]

            # sanitize request.params
            # TODO: sanitize more parameters to make searching a little more user friendly
            request.params['dept_id'] = request.params['dept_id'].upcase if request.params['dept_id']

            sorting = parse_sorting_params 'course_id'
            std_params = parse_query_v0 @course_params

            res =
              Course
                .where{Sequel.&(*std_params)}
                .order(*sorting)
                .limit(@limit)
                .offset((@page - 1)*@limit)
                .map{|c| c.to_v0}

            end_paginate! res

            return json res
          end
        end
      end
    end
  end
end
