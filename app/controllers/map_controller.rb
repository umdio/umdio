module Sinatra
  module UMDIO
    module Routing
      module Map
        # Sinatra handling
        def self.registered(app)
          app.register Sinatra::Namespace

          buildings_collection = app.settings.map_db.collection('buildings')
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
              buildings = get_buildings(buildings_collection)
              buildings.map{|e|
                e['long'] = e.delete('lng')
              }

              json buildings
            end

            # get buildings by building_id or code
            get '/buildings/:building_id' do
              buildings = get_buildings_by_id(buildings_collection, params[:building_id])
              buildings.map{|e|
                e['lon'] = e.delete('lng')
              }

              json buildings
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
              json get_buildings(buildings_collection)
            end

            # get buildings by building_id or code
            get 'buildings/:building_id' do
              json get_buildings_by_id(buildings_collection, params[:building_id])
            end
          end
        end
      end
    end
  end
end
