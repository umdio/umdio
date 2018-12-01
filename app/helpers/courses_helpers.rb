# Helper methods for courses endpoint
module Sinatra
  module UMDIO
    module Helpers

      # generalize logic for checking if semester param valid
      def check_semester app, semester, table
        # check for semester formatting
        if not (semester.length == 6 and semester.is_number?)
          halt 400, { error_code: 400, message: "Invalid semester parameter! semester must be 6 digits" }.to_json
        end

        # check if table exists
        begin
          app.settings.postgres.exec("SELECT * from #{table}#{semester} LIMIT 1")
        rescue PG::UndefinedTable
          msg = "We don't have data for this semester! If you leave off the semester parameter, we'll give you the courses currently on Testudo"
          halt 404, {error_code: 404, message: msg}.to_json
        end

        true
      end

      # helper method for printing json-formatted sections based on a sections collection and a list of section_ids
      def find_sections db, semester, section_ids
        # Turn section_ids into string
        sections = (section_ids.map {|e| "'#{e}'"}).join ','

        # This is proably ok, because we know that semester and section_ids both match expected formats
        # TODO: Take another look here, for security purposes
        res = db.exec("SELECT * FROM sections#{semester} WHERE section_id in (#{sections})")

        if !res
          halt 404, {
            error_code: 404,
            message: "Section with section_id #{section_ids[0]} not found.",
            available_sections: "https://api.umd.io/v0/courses/sections",
            docs: "http://umd.io/courses"
          }.to_json
        end

        cleaned_rows = []

        # Decode arrays and json
        res.each do |row|
          row['instructors'] = PG::TextDecoder::Array.new.decode(row['instructors'])
          row['meetings'] = PG::TextDecoder::JSON.new.decode(row['meetings'])
          cleaned_rows << row
        end

        return cleaned_rows
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
      # @return: Array of courses
      def find_courses db, semester, course_ids
        course_ids = [course_ids] if course_ids.is_a?(String)

        validate_course_ids course_ids

        # Turn course_ids into string
        courses_ids_string = (course_ids.map {|e| "'#{e}'"}).join ','

        # This is proably ok, because we know that semester and sectcourse_idsion_ids both match expected formats
        # TODO: Take another look here, for security purposes
        res = db.exec("SELECT * FROM courses#{semester} WHERE course_id in (#{courses_ids_string})")

        courses = []

        # Decode arrays and json
        res.each do |row|
          row['grading_method'] = PG::TextDecoder::Array.new.decode(row['grading_method'])
          row['core'] = PG::TextDecoder::Array.new.decode(row['core'])
          row['gen_ed'] = PG::TextDecoder::Array.new.decode(row['gen_ed'])
          row['relationships'] = PG::TextDecoder::JSON.new.decode(row['relationships'])
          row['sections'] = find_sections_for_course db, semester, row['course_id'], params[:expand]
          courses << row
        end

        # check if found
        if courses.empty?
          s = course_ids.length > 1 ? 's' : ''
          halt 404, {
            error_code: 404,
            message: "Course#{s} with course_id#{s} #{course_ids.join(',')} not found!",
            available_courses: "https://api.umd.io/v0/courses",
            docs: "http://umd.io/courses/"
          }.to_json
        end

        courses
      end

      def find_sections_for_course db, semester, course_id, expand
        sections = []
        if expand
          cleaned = []
          res = db.exec("SELECT * FROM sections#{semester} WHERE course_id='#{course_id}'")
          res.each do |row|
            row['instructors'] = PG::TextDecoder::Array.new.decode(row['instructors'])
            row['meetings'] = PG::TextDecoder::JSON.new.decode(row['meetings'])
            cleaned << row
          end

          sections = cleaned
        else
          res = db.exec("SELECT section_id FROM sections#{semester} WHERE course_id='#{course_id}'")
          res.each do |row|
            sections << row['section_id']
          end
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
