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
