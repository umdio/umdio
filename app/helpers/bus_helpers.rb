module Sinatra
  module UMDIO
    module Helpers

      def is_route_id? route_id
        route_ids = Route.all.map {|r| r.route_id}
        route_ids.include? route_id
      end

      def is_stop_id? stop_id
        stop_ids = Stop.all.map{|s| s.stop_id}
        stop_ids.include? stop_id
      end

      def bad_url_error message
        message ||= "Check your url! It doesn't seem to correspond to anything on the umd.io api. If you think it should, create an issue on our github page."
        {error_code: 400,
         message: message,
         docs: "https://docs.umd.io/bus/"}.to_json
      end

    end
  end
end