module Sinatra
  module UMDIO
    module Helpers

      def is_route_id? string
        # this is a hard-coded list of the routes. If the routes change, we'll error out. That's sucky, but I couldn't think of a smart way to do it. We should just take over everything.
        # we could get from the database, but that's ugly
        route_ids = ['701','702','703','104','105','108','109','110','111','113','114','115','116','117','118','122','124','125','126','127','128','129','130','131','132','133']
        route_ids.include?(string)
      end

      def is_stop_id? string
        true # should actually so some validation
      end

      def bad_url_error message
        message ||= "Check your url! It doesn't seem to correspond to anything on the umd.io api. If you think it should, create an issue on our github page."
        {error_code: 400,
         message: message, 
         docs: "http://umd.io/bus/"}.to_json
      end

    end
  end
end