# map controller

module Sinatra
  module UMDIO
    module Routing
      module Map

        def self.registered(app)
          buildings_collection = app.settings.map_db.collection('buildings')
          bad_id_message = "Check the building id in the url."

          app.before do
            content_type 'application/json'
          end

          app.get '/v0/map' do
            resp = {
              message: "This is the map endpoint.",
              status: "in development",
              docs: "http://umd.io/map",
            }
            json resp
          end

          # get list of all buildings with names and numbers
          app.get '/v0/map/buildings' do
            json buildings_collection.find({},{fields: {:_id => 0, :name => 1, :number => 1}}).to_a
          end

          # get buildings by building id
          app.get '/v0/map/buildings/:building_id' do
            building_ids = params[:building_id].split(",")
            building_ids.each {|building_id| halt 400, bad_url_error(bad_id_message) unless is_building_id? building_id}             
            buildings = buildings_collection.find({number: { '$in' => building_ids}},{fields: {:_id => 0}}).to_a
            # get rid of [] on single object return
            buildings = buildings[0] if building_ids.length == 1
            # prevent null being returned
            buildings = {} if not buildings
            json buildings
          end

        end
   
      end
    end
  end
end
