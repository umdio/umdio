module Sinatra
  module UMDIO
    module Routing
      module Map

        def self.registered(app)
          app.register Sinatra::Namespace

          buildings_collection = app.settings.map_db.collection('buildings')
          bad_id_message = "Check the building id in the url."

          app.namespace '/v1/map' do
            get do
              resp = {
                message: "This is the map endpoint.",
                status: "Version 1!",
                docs: "https://umd.io/map",
              }
              json resp
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
              json buildings_collection.find({},{fields: {:_id => 0}}).map { |e| e }
            end

            # get buildings by building_id or code
            get 'buildings/:building_id' do
              building_ids = params[:building_id].upcase.split(",")
              building_ids.each { |building_id| halt 400, bad_url_error(bad_id_message) unless is_building_id? building_id }

              # find building ids or building codes
              expr = {
                '$or' => [
                  { building_id: { '$in' => building_ids} },
                  { code: { '$in' => building_ids} },
                ]
              }
              buildings = buildings_collection.find(expr, { fields: {:_id => 0} }).to_a

              # throw 404 if empty
              if buildings == []
                halt 404, {
                  error_code: 404,
                  message: "Building number #{params[:building_id]} isn't in our database, and probably doesn't exist.",
                  available_buildings: "https://api.umd.io/map/buildings",
                  docs: "https://umd.io/map"
                }.to_json
              end

              json buildings
            end
          end
        end
      end
    end
  end
end
