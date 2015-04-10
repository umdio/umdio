# Helper methods for courses endpoint
module Sinatra
  module UMDIO
    module Helpers

      # helper method for printing json-formatted sections based on a sections collection and a list of section_ids
      def find_sections section_ids, section_coll
        if section_ids.length > 1
          section_coll.find({section_id: { '$in' => section_ids } },{fields: {_id: 0}}).to_a
        else
          section_coll.find({section_id: section_ids[0]}, {fields: {_id: 0}}).to_a[0] 
          # is returning the single object without [] weird? should we return the array without []?
        end
      end

      def flatten_sections sections_array
        sections_array.map { |e| e['section_id'] }
      end

      def is_course? string
        /^[A-Z]{4}\d{3}[A-Z]?$/.match string #if the string is of this particular format
      end

      def is_section? string
        /^\d{4}$/.match string #if the string is of this particular format
      end

      def is_full_section_id? string
        /^[A-Z]{4}\d{3}[A-Z]?-\d{4}$/.match string
      end

      def validate_section_ids section_ids, do_halt=true
        section_ids = [section_ids] if section_ids.is_a?(String)
        section_ids.each do |id|
          if not is_full_section_id? id
            return false if not do_halt
            error_msg = { error_code: 400, message: "Invalid section_id #{id}", docs: "http://umd.io/courses/" }.to_json
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
          if not is_course? id
            return false if not do_halt
            error_msg = { error_code: 400, message: "Invalid course_id #{id}", docs: "http://umd.io/courses/" }.to_json
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

        courses = courses.to_a

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

      # TODO: make this line up with Testudo more accurately
      def get_current_semester
        time = Time.new
        if time.month >= 3 && time.month < 10
          time.year.to_s + '08'
        else
          (time.year + 1).to_s + '01'
        end
      end
    end
  end
end
