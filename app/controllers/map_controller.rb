require_relative '../models/building.rb'

module Sinatra
  module UMDIO
    module Routing
      module Map
        # Sinatra handling
        def self.registered(app)
          app.register Sinatra::Namespace

          buildings_t = buildings_table(app.settings.DB)
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
              json get_buildings(buildings_t)
            end

            # get buildings by building_id or code
            get '/buildings/:building_id' do
              json get_buildings_by_id(buildings_t, params[:building_id])
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
              buildings = get_buildings(buildings_t)
              buildings.map{|e|
                e[:lng] = e.delete(:long)
                e[:lng] = e[:lng].to_s
                e[:lat] = e[:lat].to_s
              }
              json buildings
            end

            # get buildings by building_id or code
            get 'buildings/:building_id' do
              buildings = get_buildings_by_id(buildings_t, params[:building_id])
              buildings.map{|e|
                e[:lng] = e.delete(:long)
                e[:lng] = e[:lng].to_s
                e[:lat] = e[:lat].to_s
              }
              json buildings
            end
          end
        end
      end
    end
  end
end
