# Module for the courses endpoint is defined. Relies on helpers in courses_helpers.rb
module Sinatra
  module UMDIO
    module Routing
      module Courses
        def self.registered(app)
          # TODO: Is this needed?
          app.register Sinatra::Namespace

          app.namespace '/v1/courses' do
            course_docs_url = 'https://docs.umd.io/courses/'

            before do
              @course_params = %w[semester credits dept_id grading_method core gen_ed]
              @section_params = %w[course_id seats open_seats waitlist semester]
              @meeting_params = %w[days room building classtype start_time end_time]

              @meeting_params.each do |p|
                rename_param "meetings.#{p}", p
              end

              fix_sem

              # TODO: This could be more concise
              if request.params['expand']
                request.update_param('expand', request.params['expand'].to_s.downcase == 'sections')
              end
            end

            get '/sections/:section_id' do
              # separate into an array on commas, turn it into uppercase
              section_ids = params[:section_id].to_s.upcase.split(',')

              section_ids.each do |section_id|
                unless is_full_section_id?(section_id)
                  halt 400, bad_url_error("Invalid section_id #{section_id}", course_docs_url)
                end
              end

              # TODO: ensure this change actually worked
              res = find_sections(request.params['semester'], section_ids).map(&:to_v0)

              json res
            end

            get '/sections' do
              begin_paginate! $DB[:sections]

              sorting = parse_sorting_params 'section_id'
              std_params = parse_query_v1 @section_params
              m_std_params = parse_query_v1 @meeting_params

              if std_params == [] && m_std_params == []
                res = Section.order(*sorting)
                             .limit(@limit)
                             .offset((@page - 1) * @limit)
                             .map(&:to_v1)

                return json res
              end

              y = Meeting.where { Sequel.&(*m_std_params) } unless m_std_params == []
              y = Meeting.all if m_std_params == []

              x = Sequel.&(*std_params, meetings: y) unless std_params == []
              x = { meetings: y } if std_params == []

              res =
                Section.where(x)
                       .order(*sorting)
                       .limit(@limit)
                       .offset((@page - 1) * @limit)
                       .map(&:to_v1)

              end_paginate! res

              return json [res]
            end

            get '/semesters' do
              json Course.all_semesters
            end

            get '/departments' do
              json Course.all_depts
            end

            get '/list' do
              json(Course.list_sem(request.params['semester'])).map { |c| c.to_v1_info }
            end

            # Returns section info about particular sections of a course, comma separated
            get '/:course_id/sections/:section_id' do
              course_id = params[:course_id].to_s.upcase

              validate_course_ids course_id

              section_numbers = params[:section_id].to_s.upcase.split(',')
              # TODO: validate_section_ids
              section_numbers.each do |number|
                unless is_section_number? number
                  halt 400, bad_url_error("Invalid section number #{number}", course_docs_url)
                end
              end

              section_ids = section_numbers.map { |number| "#{course_id}-#{number}" }

              sections = (find_sections request.params['semester'], section_ids).map { |s| s.to_v1 }

              halt 404, { error_code: 404, message: 'No sections found.' }.to_json if sections.nil? || sections.empty?

              json sections
            end

            # TODO: sort??
            # Returns section objects of a given course
            get '/:course_id/sections' do
              course_id = params[:course_id].upcase
              res = find_sections_for_course_v1 request.params['semester'], course_id, true

              if res.empty?
                halt 404, {
                  error_code: 404,
                  message: "Course with course_id #{course_id} not found!",
                  available_courses: 'https://api.umd.io/v1/courses',
                  docs: course_docs_url
                }.to_json
              end

              json res
            end

            # returns courses specified by :course_id
            get '/:course_id' do
              course_ids = params[:course_id].upcase.split(',')
              courses = find_courses_v1 request.params['semester'], course_ids, request.params

              json courses
            end

            # returns a paginated list of courses, with the full course objects
            get do
              begin_paginate! $DB[:courses]

              upper_param 'dept_id'

              sorting = parse_sorting_params 'course_id'
              std_params = parse_query_v1 @course_params

              res =
                Course
                .where { Sequel.&(*std_params) }
                .order(*sorting)
                .limit(@limit)
                .offset((@page - 1) * @limit)
                .map { |c| c.to_v1 }

              end_paginate! res

              res.each do |c|
                c[:sections] = find_sections_for_course_v1 request.params['semester'], c[:course_id], request.params['expand']
              end

              return json res
            end
          end

          # BEGIN v0

          app.before '/v0/courses*' do
            @course_params = %w[semester course_id credits dept_id grading_method core gen_ed name]
            @section_params = %w[section_id_str course_id seats semester]
            @meeting_params = %w[days room building classtype start_time end_time]

            @meeting_params.each do |p|
              rename_param "meetings.#{p}", p
            end

            fix_sem
            check_semester app, request.params['semester']

            rename_param 'section_id', 'section_id_str'

            # TODO: This could be more concise
            if request.params['expand']
              request.update_param('expand', request.params['expand'].to_s.downcase == 'sections')
            end
          end

          # Returns sections of courses by their id
          app.get '/v0/courses/sections/:section_id' do
            # separate into an array on commas, turn it into uppercase
            section_ids = params[:section_id].to_s.upcase.split(',')

            section_ids.each do |section_id|
              unless is_full_section_id? section_id
                halt 400, bad_url_error("Invalid section_id #{section_id}", 'https://docs.umd.io/courses/')
              end
            end

            res = (find_sections request.params['semester'], section_ids).map { |s| s.to_v0 }

            # If we only have 1 result, we have to just return it (for compatibility)
            # TODO (v1): Fix this
            return json res[0] if res.length == 1

            json res
          end

          app.get '/v0/courses/sections' do
            begin_paginate! $DB[:sections]

            sorting = parse_sorting_params 'section_id'
            std_params = parse_query_v0 @section_params
            m_std_params = parse_query_v0 @meeting_params

            if (std_params == []) && (m_std_params == [])
              res = Section.order(*sorting)
                           .limit(@limit)
                           .offset((@page - 1) * @limit)
                           .map { |s| s.to_v0 }

              return json res
            end

            y = Meeting.where { Sequel.&(*m_std_params) } unless m_std_params == []
            y = Meeting.all if m_std_params == []

            x = Sequel.&(*std_params, meetings: y) unless std_params == []
            x = { meetings: y } if std_params == []

            res =
              Section
              .where(x)
              .order(*sorting)
              .limit(@limit)
              .offset((@page - 1) * @limit)
              .map { |s| s.to_v0 }
            end_paginate! res
            return json [res]
          end

          # all of the semesters that we have
          app.get '/v0/courses/semesters' do
            json Course.all_semesters
          end

          app.get '/v0/courses/departments' do
            json Course.all_depts
          end

          app.get '/v0/courses/list' do
            json(Course.list_sem(request.params['semester'])).map { |c| c.to_v0_info }
          end

          # Returns section info about particular sections of a course, comma separated
          app.get '/v0/courses/:course_id/sections/:section_id' do
            course_id = params[:course_id].to_s.upcase

            validate_course_ids course_id

            section_numbers = params[:section_id].to_s.upcase.split(',')
            # TODO: validate_section_ids
            section_numbers.each do |number|
              unless is_section_number? number
                halt 400, bad_url_error("Invalid section number #{number}", 'https://docs.umd.io/courses/')
              end
            end

            section_ids = section_numbers.map { |number| "#{course_id}-#{number}" }

            sections = (find_sections request.params['semester'], section_ids).map { |s| s.to_v0 }

            halt 404, { error_code: 404, message: 'No sections found.' }.to_json if sections.nil? || sections.empty?

            json sections
          end

          # TODO: sort??
          # Returns section objects of a given course
          app.get '/v0/courses/:course_id/sections' do
            course_id = params[:course_id].upcase
            res = find_sections_for_course request.params['semester'], course_id, true

            if res.empty?
              halt 404, {
                error_code: 404,
                message: "Course with course_id #{course_id} not found!",
                available_courses: 'https://api.umd.io/v0/courses',
                docs: 'https://docs.umd.io/courses/'
              }.to_json
            end

            json res
          end

          # returns courses specified by :course_id
          # MAYBE     if a section_id is specified, returns sections info as well
          # MAYBE     if only a department is specified, acts as a shortcut to search with ?dept=<param>
          app.get '/v0/courses/:course_id' do
            # parse request.params
            course_ids = params[:course_id].to_s.upcase.split(',')

            courses = find_courses request.params['semester'], course_ids, request.params

            # TODO: get rid of this
            # get rid of [] on single object return
            courses = courses[0] if course_ids.length == 1
            # prevent null being returned
            courses ||= {}

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
              .where { Sequel.&(*std_params) }
              .order(*sorting)
              .limit(@limit)
              .offset((@page - 1) * @limit)
              .map { |c| c.to_v0 }

            end_paginate! res

            res.each do |c|
              c[:sections] = find_sections_for_course request.params['semester'], c[:course_id], request.params['expand']
            end

            return json res
          end
        end
      end
    end
  end
end
