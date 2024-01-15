# map helpers

module Sinatra
  module UMDIO
    module Helpers
      ##
      # Gets buildings by their numerical ids or buildling codes.
      #
      # @param [String] id a comma-separated list of building ids or codes
      #
      # @return [Array] The query result
      #
      def get_buildings_by_id(id)
        bad_id_message = 'Check the building id in the url.'
        doc_url = 'https://beta.umd.io/#tag/map'

        building_ids = id.upcase.split(',')
        building_ids.each do |building_id|
          halt 400, bad_url_error(bad_id_message, doc_url) unless is_building_id? building_id
        end

        buildings = Building.where(id: building_ids).or(code: building_ids).to_a

        # throw 404 if empty
        if buildings == []
          halt 404, {
            error_code: 404,
            message: "Building number #{params[:building_id]} isn't in our database, and probably doesn't exist.",
            available_buildings: 'https://api.umd.io/v0/map/buildings',
            docs: 'https://beta.umd.io/#tag/map'
          }.to_json
        end

        buildings
      end

      # is it a building id? We don't know until we check the database. This determines if it is at least possible
      def is_building_id?(string)
        string.length < 6 && string.length > 2
      end
    end
  end
end
