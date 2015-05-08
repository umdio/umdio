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
