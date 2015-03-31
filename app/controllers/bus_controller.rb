# buses controller

module Sinatra
  module UMDIO
    module Routing
      module Bus

        def self.registered(app)

          #this should probably be a more specific error message where we error out!
          bad_route_message = "umd.io doesn't know the bus route in your url. It should be three digits, and you can find the full list at /bus/routes"
          apiRoot = 'http://webservices.nextbus.com/service/publicJSONFeed?a=umd'
          require 'net/http'

          app.before do
            content_type 'application/json'
          end

          # # root of bus endpoint
          # app.get '/v0/bus' do
          #   # not sure what this returns!!
          # end

          # lists bus routes
          app.get '/v0/bus/routes' do
            address = apiRoot + '&command=routeList'
            Net::HTTP.get(URI(address)).to_s
          end

          # in nextbus api terms, this is routeConfig - the info for a route
          app.get '/v0/bus/routes/:route_id' do
             route_id = params[:route_id]
             halt 400, bad_url_error(bad_route_message) unless is_route_id? route_id
             address = apiRoot + "&command=routeConfig"
             Net::HTTP.get(URI(address + "&r=#{route_id}")).to_s
          end

          # schedule for a route
          app.get '/v0/bus/routes/:route_id/schedule' do
            route_id = params[:route_id]
             halt 400, bad_url_error(bad_route_message) unless is_route_id? route_id
            address = apiRoot + "&command=schedule"
            Net::HTTP.get(URI(address + "&r=#{route_id}")).to_s
          end

          #  next arriving buses for a particular stop on the route (in nextbus, the predictions)
          app.get '/v0/bus/routes/:route_id/arrivals/:stop_id' do
            route_id = params[:route_id]
            halt 400, bad_url_error(bad_route_message) unless is_route_id? route_id
            address  = apiRoot + "?command=predictions&a=umd"
            Net::HTTP.get(URI(address + "&r=#{route_id}&s=#{params[:stop_id]}")).to_s #this weirdness is from nextbus's api. I swear.
          end

          # locations of buses on route
          app.get '/v0/bus/routes/:route_id/locations' do
            route_id = params[:route_id]
            halt 400, bad_url_error(bad_route_message) unless is_route_id? route_id
            address = apiRoot + "&command=vehicleLocations"
            Net::HTTP.get(URI(address + "&r=#{route_id}")).to_s
          end

          app.get '/v0/bus/locations' do
            address = apiRoot + "&command=vehicleLocations"
            Net::HTTP.get(URI(address)).to_s
          end

          # # list all stops -- this is a little challenging, I'll leave it for later
          # app.get 'v0/bus/stops'

          # end

          # # get info about a stop -- this one is the same level of challenge as /stops. We need to collect the data about all the stops, which is a bit of a pain
          # app.get 'v0/bus/stops/:stop_id' do
            
          # end

          # # get predicted arrivals for a stop -- this one isn't working because the NextBus API docs lie. Frustrating.
          # app.get 'v0/bus/stops/:stop_id/arrivals'
            
          # end

          
        end
      end
    end
  end
end
