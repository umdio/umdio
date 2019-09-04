require_relative '../models/building.rb'

module Sinatra
  module UMDIO
    module Routing
      module Map
        # Sinatra handling
        def self.registered(app)
          app.register Sinatra::Namespace

          bad_id_message = "Check the building id in the url."

          app.namespace '/v1/map' do
            get do
              resp = {
                message: "This is the map endpoint.",
                version: "1.0.0",
                docs: "https://umd.io/map",
                endpoints: ["/buildings", "/buildings/{:building_id}"]
              }
              json resp
            end

            # get list of all buildings with names and numbers
            get '/buildings' do
              json Building.all.map {|b| b.to_v1}
            end

            # get buildings by building_id or code
            get '/buildings/:building_id' do
              json get_buildings_by_id(params[:building_id]).map {|b| b.to_v1}
            end
          end

          app.namespace '/v*/map' do
            get do
              resp = {
                message: "This is the map endpoint.",
                status: "in development",
                docs: "https://umd.io/map",
              }
              json resp
            end

            # get list of all buildings with names and numbers
            get '/buildings' do
              json Building.all.map {|b| b.to_v0}
            end

            # get buildings by building_id or code
            get '/buildings/:building_id' do
              buildings = get_buildings_by_id(params[:building_id])
              json buildings.map{|b| b.to_v0 }
            end
          end
        end
      end
    end
  end
end
