# Helper methods for courses endpoint
module Sinatra
  module UMDIO
    module Helpers

      # Generic course helpers

      # generalize logic for checking if semester param valid
      def check_semester app, semester
        # check for semester formatting
        if not (semester.length == 6 and semester.is_number?)
          halt 400, { error_code: 400, message: "Invalid semester parameter! semester must be 6 digits" }.to_json
        end

        if Course.where(semester: semester).to_a.length == 0
          halt 400, { error_code: 400, message: "We don't have data for this semester!" }.to_json
        end
      end

      # helper method for printing json-formatted sections based on a sections collection and a list of section_ids
      def find_sections semester, section_ids
        res = Section.where(semester: semester, section_id_str: section_ids)

        if !res
          halt 404, {
            error_code: 404,
            message: "Section with section_id #{section_ids[0]} not found.",
            available_sections: "https://api.umd.io/v0/courses/sections",
            docs: "https://docs.umd.io/courses"
          }.to_json
        end

        return res
      end


      def validate_section_ids section_ids, do_halt=true
        section_ids = [section_ids] if section_ids.is_a?(String)
        section_ids.each do |id|
          if not is_full_section_id? id
            return false if not do_halt
            halt 400, bad_url_error("Invalid section_id #{id}.", "https://docs.umd.io/courses/")
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
            halt 400, bad_url_error("Invalid course_id #{id}.", "https://docs.umd.io/courses/")
          end
        end

        return true
      end

      # gets a single course or an array or courses and halts if none are found
      # @return: Array of courses
      def find_courses_v1 semester, course_ids, params
        course_ids = [course_ids] if course_ids.is_a?(String)

        validate_course_ids course_ids

        courses = Course.where(semester: semester, course_id: course_ids).map{|c| c.to_v1}
        # check if found
        if courses.empty?
          s = course_ids.length > 1 ? 's' : ''
          halt 404, {
            error_code: 404,
            message: "Course#{s} with course_id#{s} #{course_ids.join(',')} not found!",
            available_courses: "https://api.umd.io/v0/courses",
            docs: "https://docs.umd.io/courses/"
          }.to_json
        end

        courses.each{|c| c['sections'] = find_sections_for_course_v1 semester, c[:course_id], params['expand']}
        courses
      end

      def find_sections_for_course_v1 semester, course_id, expand
        sections = []

        if expand
          sections = Section.where(semester: semester, course_id: course_id).map{|s| s.to_v1}
        else
          sections = Section.where(semester: semester, course_id: course_id).map{|s| s[:section_id_str]}
        end

        return sections
      end

      # gets a single course or an array or courses and halts if none are found
      # @return: Array of courses
      def find_courses semester, course_ids, params
        course_ids = [course_ids] if course_ids.is_a?(String)

        validate_course_ids course_ids

        courses = Course.where(semester: semester, course_id: course_ids).map{|c| c.to_v0}
        # check if found
        if courses.empty?
          s = course_ids.length > 1 ? 's' : ''
          halt 404, {
            error_code: 404,
            message: "Course#{s} with course_id#{s} #{course_ids.join(',')} not found!",
            available_courses: "https://api.umd.io/v0/courses",
            docs: "https://docs.umd.io/courses/"
          }.to_json
        end

        courses.each{|c| c['sections'] = find_sections_for_course semester, c[:course_id], params['expand']}
        courses
      end

      def find_sections_for_course semester, course_id, expand
        sections = []

        if expand
          sections = Section.where(semester: semester, course_id: course_id).map{|s| s.to_v0}
        else
          sections = Section.where(semester: semester, course_id: course_id).map{|s| s[:section_id_str]}
        end

        return sections
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

      def current_semester
        # Testudo schedules updated mid/late September for Spring, mid/late Feb for fall
        # advisor calendar found here http://registrar.umd.edu/faculty-staff/
        month = Time.now.month
        year = Time.now.year
        if month >= 3 && month <= 10
          "#{year}08"
        else
          "#{([11,12].include?(month) ? year + 1 : year)}01"
        end
      end

      def current_and_next_semesters
        month = Time.now.month
        year = Time.now.year
        if month >= 1 && month <= 2
          ["#{year}01"]
        elsif month >= 3 && month <= 5
          ["#{year}01", "#{year}05", "#{year}08"]
        elsif month >= 6 && month <= 8
          ["#{year}05", "#{year}08"]
        elsif month >= 9 && month <= 9
          ["#{year}08"]
        elsif month >= 10 && month <= 12
          ["#{year}08", "#{year}12", "#{year+1}01"]
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
