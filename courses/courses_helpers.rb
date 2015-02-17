#Helper methods for courses endpoint
module Sinatra
  module UMDIO
    module Helpers

      #helper method for printing json-formatted sections based on a sections collection and a list of section_ids
      def json_sections section_ids, sections
        if section_ids.length > 1
          json sections.find({section_id: { '$in' => section_ids } },{fields: {_id: 0}}).to_a
        else
          json sections.find({section_id: section_ids[0]}, {fields: {_id: 0}}).to_a[0] # question about whether to remove brackets or not
        end
      end

      def list_all_courses courses
        json courses.find({},{:fields =>{:_id => 0, :department => 1, :course_id => 1, :name => 1}}).to_a #should be a lambda
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
      #   pattern = /(([a-zA-Z]{4})(\d{3}([a-zA-Z])?)?)-?(\d{4})?/
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
