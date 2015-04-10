# Module for the courses endpoint is defined. Relies on helpers in courses_helpers.rb

module Sinatra
  module UMDIO
    module Routing
      module Courses

        def self.registered(app)

          course_coll = nil
          section_coll = nil

          app.before '/v0/courses*' do
            # TODO: don't hard code the current semester
            params[:semester] ||= '201508'

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

            course_coll = app.settings.courses_db.collection("courses#{params[:semester]}")
            section_coll = app.settings.courses_db.collection("sections#{params[:semester]}")
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

            json find_sections section_ids, section_coll #using helper method
          end

          # should this give error or it could do something like courses/list except with sections array too?
          app.get '/v0/courses/sections' do
            # TODO does this really exist? What do we return on this?
            { error_code: 404, message: "We still don't know what should be returned here. Do you?" }.to_json
          end

          # Returns section info about particular sections of a course, comma separated
          app.get '/v0/courses/:course_id/sections/:section_id' do
            course_id = "#{params[:course_id]}".upcase

            validate_course_ids course_id

            section_numbers = "#{params[:section_id]}".upcase.split(',')
            # TODO: validate_section_ids
            section_numbers.each do |number|
              if not is_section? number
                halt 400, { error_code: 400, message: "Invalid section_number #{number}" }.to_json
              end
            end

            section_ids = section_numbers.map { |number| "#{course_id}-#{number}" }
            sections = find_sections section_ids, section_coll

            if sections.nil? or sections.empty?
              halt 404, { error_code: 404, message: "No sections found." }.to_json
            end

            json sections
          end

          # Returns section objects of a given course
          app.get '/v0/courses/:course_id/sections' do
            course_id = "#{params[:course_id]}".upcase

            courses = find_courses course_coll, course_id
            section_ids = courses[0]['sections'].map { |e| e['section_id'] }

            json find_sections section_ids,section_coll
          end

          # returns courses specified by :course_id
          # MAYBE     if a section_id is specified, returns sections info as well
          # MAYBE     if only a department is specified, acts as a shortcut to search with ?dept=<param>
          app.get '/v0/courses/:course_id' do
            # parse params
            course_ids = "#{params[:course_id]}".upcase.split(',')

            courses = find_courses course_coll, course_ids

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

          # returns a list of courses, with the full course objects. This is probably not what we want in the end
          app.get '/v0/courses' do
            # sorting
            sorting = []
            params['sort'] ||= []
            params['sort'].split(',').each do |sort|
              order_str = '+'
              if sort[0] == '+' or sort[0] == '-'
                order_str = sort[0]
                sort = sort[1..sort.length]
              end
              order = (order_str == '+' ? 1 : -1)
              sorting << sort
              sorting << order
            end unless params['sort'].empty?

            # searching
            params.delete('sort')
            params.delete('semester')
            query = {}
            params.keys.each do |k|
              e = ''
              if k.include? ('<')
                parts = k.split('<')
                if parts.length == 1
                  parts[1] = params[k]
                  e = 'e'
                end
                query[parts[0]] = { "$lt#{e}" => parts[1] }
              elsif k.include? ('>')
                parts = k.split('>')
                if parts.length == 1
                  parts[1] = params[k]
                  e = 'e'
                end
                query[parts[0]] = { "$gt#{e}" => parts[1] }
              else
                query[k] = params[k]
              end
            end

            #require 'pry'; binding.pry

            json course_coll.find(query, {:sort => sorting, :fields =>{:_id => 0, :department => 1, :course_id => 1, :name => 1}}).map{ |e| e }
          end

        end

      end
    end
  end
end
