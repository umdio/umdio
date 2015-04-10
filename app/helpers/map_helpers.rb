# map helpers

module Sinatra
  module UMDIO
    module Helpers

      # is it a building id? We don't know until we check the database. This determines if it is at least possible
      def is_building_id? string
        string.length < 6 && string.length > 2
      end

      # can this be a more general helper method? Where else can we use that?
      def bad_url_error message
        message ||= "Check your url! It doesn't seem to correspond to anything on the umd.io api. If you think it should, create an issue on our github page."
        {error_code: 400,
         message: message, 
         docs: "http://umd.io/maps/"}.to_json
      end

    end
  end
end