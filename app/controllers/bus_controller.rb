# buses controller

module Sinatra
  module UMDIO
    module Routing
      module Bus

        def self.registered(app)
          #this should probably be a more specific error message where we error out!
          bad_route_message = "umd.io doesn't know the bus route in your url. Full list at https://api.umd.io/v0/bus/routes"
          bad_stop_message = "umd.io doesn't know the stop in your url. Full list at https://api.umd.io/v0/bus/routes"
          apiRoot = 'http://webservices.nextbus.com/service/publicJSONFeed?a=umd'
          require 'net/http'

          # root of bus endpoint
           app.get '/v0/bus' do
              resp = {
                message: "This is the bus endpoint.",
                status: "working (we think!)",
                docs: "https://umd.io/bus/",
              }
              json resp
           end

          # lists bus routes
          app.get '/v0/bus/routes' do
            json Route.all.map{|r| r.to_v0_info}
          end

          # get info about one or more routes
          # in nextbus api terms, this is routeConfig - the info for a route
          app.get '/v0/bus/routes/:route_id' do
            route_ids = params[:route_id].downcase.split(",")
            route_ids.each {|route_id| halt 400, bad_url_error(bad_route_message) unless is_route_id? route_id}
            routes = Route.where(route_id: route_ids).map {|r| r.to_v0}
            # get rid of [] on single object return
            routes = routes[0] if route_ids.length == 1
            # prevent null being returned
            # Never gets hit, because we are checking a hard-coded list of routes.
            # We should be consistent in how we do this instead of this haphazard approach...
            routes = {} if not routes
            json routes
          end

          # schedules for a route
          # schedules are updated along with routes every semester or so
          app.get '/v0/bus/routes/:route_id/schedules' do
            cache_control :public, :must_revalidate, max_age: 60*60

            route_id = params[:route_id]
            halt 400, bad_url_error(bad_route_message) unless is_route_id? route_id
            # address = apiRoot + "&command=schedule"
            # Net::HTTP.get(URI(address + "&r=#{route_id}")).to_s
            #json schedules_collection.find({route: route_id},{fields:{_id:0,schedule_class:0}}).to_a
            json Schedule.where(route_id: route_id).map{|r| r.to_v0}
          end

          # next arriving buses for a particular stop on the route (in nextbus, the predictions)
          # Not sure how/whether to set this one up for polling & adding to the database. leaving it for now
          app.get '/v0/bus/routes/:route_id/arrivals/:stop_id' do
            cache_control :public, :must_revalidate, max_age: 60

            route_id = params[:route_id]
            stop_id = params[:stop_id]
            halt 400, bad_url_error(bad_route_message)  unless is_route_id? route_id
            halt 400, bad_url_error(bad_stop_message) unless is_stop_id? stop_id
            address  = apiRoot + "&command=predictions"
            Net::HTTP.get(URI(address + "&r=#{route_id}&s=#{stop_id}")).to_s #this weirdness is from nextbus's api. I swear.
          end

          # locations of buses on route
          app.get '/v0/bus/routes/:route_id/locations' do
            cache_control :public, :must_revalidate, :no_cache, max_age: 60

            route_id = params[:route_id]
            halt 400, bad_url_error(bad_route_message) unless is_route_id? route_id
            address = apiRoot + "&command=vehicleLocations"
            Net::HTTP.get(URI(address + "&r=#{route_id}")).to_s
          end

          # locations of all buses
          app.get '/v0/bus/locations' do
            cache_control :public, :must_revalidate, max_age: 60

            address = apiRoot + "&command=vehicleLocations"
            Net::HTTP.get(URI(address)).to_s
          end

          # list the bus stops
          app.get '/v0/bus/stops' do
            json Stop.all.map{|s| s.to_v0}
          end

          # get info about a particular bus stop
          app.get '/v0/bus/stops/:stop_id' do
            stop_id = params[:stop_id]
            halt 400, bad_url_error(bad_stop_message) unless is_stop_id? stop_id
            json Stop.where(stop_id: stop_id).map {|s| s.to_v0}
          end

          # get predicted arrivals for a stop -- this one isn't working because the NextBus API docs lie. Frustrating.
          # app.get 'v0/bus/stops/:stop_id/arrivals'

          # end

        end
      end
    end
  end
end
