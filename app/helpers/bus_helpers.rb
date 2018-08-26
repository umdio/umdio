module Sinatra
  module UMDIO
    module Helpers

      def is_route_id?(coll, route)
        routes = coll.find({},{fields: {:_id => 0, :route_id => 1, :title => 1}}).to_a
        route_ids = []
        routes.each {|route|
          route_ids.push(route['route_id'])
        }
        route_ids.include?(route)
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