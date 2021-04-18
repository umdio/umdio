# frozen_string_literal: true

module Sinatra
  module UMDIO
    module Helpers
      def is_route_id?(route_id)
        route_ids = Route.all.map(&:route_id)
        route_ids.include? route_id
      end

      def is_stop_id?(stop_id)
        stop_ids = Stop.all.map(&:stop_id)
        stop_ids.include? stop_id
      end
    end
  end
end
