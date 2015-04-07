#Helper methods for courses endpoint
module Sinatra
  module UMDIO
    module Helpers

      #helper method for printing json-formatted sections based on a sections collection and a list of section_ids
      def find_sections section_ids, section_coll
        if section_ids.length > 1
          section_coll.find({section_id: { '$in' => section_ids } },{fields: {_id: 0}}).to_a
        else
          section_coll.find({section_id: section_ids[0]}, {fields: {_id: 0}}).to_a[0] 
          # is returning the single object without [] weird? should we return the array without []?
        end
      end

      def find_all_courses course_coll
        course_coll.find({},{:fields =>{:_id => 0, :department => 1, :course_id => 1, :name => 1}}).map{|e|e} #less memory-intensive than .to_a
      end

      # this is no longer used, and we probably need to write a different helper for search -- move to deprecate
      def find_all_courses_full course_coll
        course_coll.find({},{:fields =>{:_id => 0}}).map{|e|e} #less memory-intensive than .to_a
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


# Haven't found occassion to use these helpers yet, but when I need them, they are here!

      # #helper method to capture relevant parts of a string
      # def pattern_match string
      #   #this is a complicated-looking pattern. It matches strings like enes100, enes, Enes100 ENES, ENGL398b, and ENES100-0101.
      #   #capture groups are as follows: 1 - full course code, 2 - dep code, 3 - course number, 4 - unused letter specifier, 5 - section number
      #   #we'll still need to sanitize them, because the database doesn't like
      # pattern = /(([A-Z]{4})(\d{3}([A-Z])?)?)-?(\d{4})?/i
      #   pattern.match(string)
      # end

      # #returns the course code from a string
      # def course string
      #   match = pattern_match string
      #   if match and match[3] then match[1] else nil end
      # end

      # #returns department code from a string
      # def dep string
      #   match = pattern_match string
      #   if match then match[2] else nil end
      # end

      # #returns section number from a string
      # def section string
      #   match = pattern_match string
      #   if match then match[-1] else nil end
      # end
