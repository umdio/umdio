#Helper methods for courses endpoint
module Sinatra
  module UMDIO
    module Helpers

      #helper method for printing json-formatted sections based on a sections collection and a list of section_ids
      def find_sections section_ids, sections
        if section_ids.length > 1
          sections.find({section_id: { '$in' => section_ids } },{fields: {_id: 0}}).to_a
        else
          sections.find({section_id: section_ids[0]}, {fields: {_id: 0}}).to_a[0] 
          # is returning the single object without [] weird? should we return the array without []?
        end
      end

      def find_all_courses courses
        courses.find({},{:fields =>{:_id => 0, :department => 1, :course_id => 1, :name => 1}}).map{|e|e} #less memory-intensive than .to_a
      end

      def flatten_sections sections_array
        sections_array.map { |e| e['section_id'] }
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
      # pattern = /(([a-zA-Z]{4})(\d{3}([a-zA-Z])?)?)-?(\d{4})?/
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
