# Helper methods for courses endpoint
module Sinatra
  module UMDIO
    module Helpers

      # helper method for printing json-formatted sections based on a sections collection and a list of section_ids
      def find_sections section_coll, section_ids
        query = section_ids[0]
        query = { '$in' => section_ids } if section_ids.length > 1

        res = section_coll.find(
          { section_id: query },
          { fields: {_id: 0, 'meetings.start_seconds' => 0, 'meetings.end_seconds' => 0} }
        ).map { |e| e }

        # is returning the single object without [] weird? should we return the array without []?
        if section_ids.length == 1
          return res[0]
        end

        if !res 
          halt 404, {
            error_code: 404, 
            message: "Section with section_id #{section_ids[0]} not found.", 
            available_sections: "http://api.umd.io/v0/courses/sections",
            docs: "http://umd.io/courses"
          }.to_json
        end

        return res
      end

      # returns an array of the section ids of an array of sections
      def flatten_sections sections_array
        if sections_array.nil?
          []
        else
          sections_array.map { |e| e['section_id'] }
        end
      end

      def begin_paginate! default_per_page=30, max_per_page=100
        # clamp page and per_page params
        params['page'] = (params['page'] || 1).to_i
        params['page'] = 1 if params['page'] < 1

        params['per_page'] = (params['per_page'] || default_per_page).to_i
        params['per_page'] = max_per_page if params['per_page'] > max_per_page
        params['per_page'] = 1 if params['per_page'] < 1

        @limit = params['per_page']
        @page  = params['page']

        # create the next & prev page links
        path = request.fullpath.split('?')[0]
        base = base_url + path + '?'
        
        # next page
        params['page'] += 1
        @next_page = base + params.map{|k,v| "#{k}=#{v}"}.join('&')

        # prev page
        params['page'] -= 2
        if (params['page']*@limit > @course_coll.count)
          params['page'] = (@course_coll.count.to_f / limit).ceil.to_i
        end
        @prev_page = base + params.map{|k,v| "#{k}=#{v}"}.join('&')
      end

      def end_paginate! courses
        # set the link headers
        link = ""
        link += "<#{@next_page}>; rel=\"next\"" unless courses.empty?
        if not courses.empty? and @page > 1
          link += ", "
        end
        link += "<#{@prev_page}>; rel=\"prev\"" unless @page == 1
        headers['Link'] = link
        headers['X-Total-Count'] = @course_coll.count.to_s
      end

      def params_sorting_array default=''
        sorting = []
        params['sort'] ||= default
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

        return sorting
      end

      # TODO: support fuzzy equals for sections like "MWF," give me all sections with class on Mondays. Should days be an array?
      def params_search_query ignore=nil
        ignore ||= @special_params

        query = {}
        params.keys.each do |k| unless ignore.include?(k)
          e = ''
          if k.include? ('<') or k.include? ('>')
            delim = ((k.include? ('<')) ? '<' : '>')
            cmp   = ((delim ==    '<')  ? 'l' : 'g')
            parts = k.split(delim)
            if parts.length == 1
              parts[1] = params[k]
              e = 'e'
            end
            query[parts[0]] = { "$#{cmp}t#{e}" => parts[1] }
          elsif k.include? ('!')
            parts = k.split('!')
            if params[k].include? (',') or params[k].include? ('|')
              delim = (params[k].include?(',') ? ',' : '|')
              query[parts[0]] = { "$nin" => params[k].split(delim) }
            else
              query[parts[0]] = { "$ne" => params[k] }
            end
          elsif not params[k].nil?
            if params[k].include? (',')
              query[k] = { "$in" => params[k].split(',') }
            elsif params[k].include? ('|')
              query[k] = { "$all" => params[k].split('|') }
            else
              query[k] = params[k]
            end
          end
        end
        end

        return query
      end

      # flattens course sections and expands them if params[:expand] is set
      def flatten_course_sections_expand section_coll, courses
        # flatten sections
        section_ids = []
        courses.each do |course|
          course['sections'] = flatten_sections course['sections']
          section_ids.concat course['sections']
        end

        # expand sections if ?expand=sections
        if params[:expand] == 'sections'
          sections = find_sections section_coll, section_ids
          sections = [sections] if not sections.kind_of?(Array) # hacky, maybe modify find_sections?

          # map sections to course hash & replace section data
          if not sections.empty?
            course_sections = sections.group_by { |e| e['course'] }
            courses.each { |course| course['sections'] = course_sections[course['course_id']] }
          end
        end

        return courses
      end

      def validate_section_ids section_ids, do_halt=true
        section_ids = [section_ids] if section_ids.is_a?(String)
        section_ids.each do |id|
          if not is_full_section_id? id
            return false if not do_halt
            error_msg = { error_code: 400, message: "Invalid section_id #{id}.", docs: "http://umd.io/courses/" }.to_json
            halt 400, error_msg
          end
        end

        return true
      end

      # validates course ids and halts if do_halt is true
      # @param course_ids : String or Array of course ids
      # @return boolean
      def validate_course_ids course_ids, do_halt=true
        course_ids = [course_ids] if course_ids.is_a?(String)
        course_ids.each do |id|
          if not is_course_id? id
            return false if not do_halt
            error_msg = { error_code: 400, message: "Invalid course_id #{id}.", docs: "http://umd.io/courses/" }.to_json
            halt 400, error_msg
          end
        end

        return true
      end

      # gets a single course or an array or courses and halts if none are found
      # @param collection : MongoDB Collection
      # @param course_ids : String or Array of course ids
      # @return: Array of courses
      def find_courses collection, course_ids
        course_ids = [course_ids] if course_ids.is_a?(String)

        validate_course_ids course_ids

        # query db
        if course_ids.length > 1
          courses = collection.find(
            { course_id: { '$in' => course_ids } },
            { fields: { _id:0, 'sections._id' => 0 } }
          )
        else
          courses = collection.find(
            { course_id: course_ids[0] },
            { fields: { _id:0, 'sections._id' => 0 } }
          )
        end

        # to_a, map is more memory efficient
        courses = courses.map { |e| e }

        # check if found
        if courses.empty?
          s = course_ids.length > 1 ? 's' : ''
          halt 404, {
            error_code: 404,
            message: "Course#{s} with course_id#{s} #{course_ids.join(',')} not found!",
            available_courses: "http://api.umd.io/v0/courses",
            docs: "http://umd.io/courses/"
          }.to_json
        end

        courses
      end

      # @param string_time string in format like 10:00am, 10:00, 10am or 10
      def time_to_int time
        time = time.to_s if time.is_a? (Fixnum)
        if time.length == 2
          time += ( time.to_i >= 12 ? 'pm' : 'am' )
        end

        require 'date'
        if dt = DateTime.parse(time) rescue false
          return dt.hour * 3600 + dt.min * 60
        end

        # all else fails, return the original time
        time.to_i
      end

      # TODO: make this line up with Testudo accurately and implement it in course controller
      def get_current_semester
        time = Time.new
        if time.month >= 3 && time.month < 10
          time.year.to_s + '08'
        else
          (time.year + 1).to_s + '01'
        end
      end

      def is_course_id? string
        /^[A-Z]{4}\d{3}[A-Z]?$/.match string #if the string is of this particular format
      end

      def is_section_number? string
        /^[A-Za-z0-9]{4}$/.match string #if the string is of this particular format
      end

      def is_full_section_id? string
        /^[A-Z]{4}\d{3}[A-Z]?-[A-Za-z0-9]{4}$/.match string
      end
    end
  end
end
