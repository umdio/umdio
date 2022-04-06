# buses controller

module Sinatra
  module UMDIO
    module Routing
      module Bus
        def self.registered(app)
          app.namespace '/v1/bus' do
            # this should probably be a more specific error message where we error out!
            bad_route_message = "umd.io doesn't know the bus route in your url. Full list at https://api.umd.io/v1/bus/routes"
            bad_stop_message = "umd.io doesn't know the stop in your url. Full list at https://api.umd.io/v1/bus/routes"
            bus_docs_url = 'https://beta.umd.io/#tags/bus'
            api_root = 'https://retro.umoiq.com/service/publicJSONFeed?a=umd'
            require 'net/http'

            get do
              resp = {
                message: 'This is the bus endpoint.',
                docs: 'https://beta.umd.io/#tags/bus/'
              }
              json resp
            end

            get '/routes' do
              json Route.all.map(&:to_v1_info)
            end

            get '/routes/:route_id' do
              route_ids = params[:route_id].downcase.split(',')
              route_ids.each do |route_id|
                halt 400, bad_url_error(bad_route_message, bus_docs_url) unless is_route_id? route_id
              end
              routes = Route.where(route_id: route_ids).map(&:to_v1)

              halt 404, not_found_error('No routes found.', 'https://beta.umd.io/#tags/bus/') if routes == []
              json routes
            end

            get '/routes/:route_id/schedules' do
              route_id = params[:route_id]
              halt 400, bad_url_error(bad_route_message, bus_docs_url) unless is_route_id? route_id
              res = Schedule.where(route: route_id).map(&:to_v1)

              halt 404, not_found_error('No routes found.', 'https://beta.umd.io/#tags/bus/') if res == []
              json res
            end

            # next arriving buses for a particular stop on the route (in nextbus, the predictions)
            # Not sure how/whether to set this one up for polling & adding to the database. leaving it for now
            get '/routes/:route_id/arrivals/:stop_id' do
              cache_control :public, :must_revalidate, max_age: 60

              route_id = params[:route_id]
              stop_id = params[:stop_id]

              halt 400, bad_url_error(bad_route_message, bus_docs_url) unless is_route_id? route_id
              halt 400, bad_url_error(bad_stop_message, bus_docs_url) unless is_stop_id? stop_id
              wrapRequest(api_root + "&command=predictions&r=#{route_id}&s=#{stop_id}")
            end

            # locations of buses on route
            get '/routes/:route_id/locations' do
              cache_control :public, :must_revalidate, :no_cache, max_age: 60

              route_id = params[:route_id]

              halt 400, bad_url_error(bad_route_message, bus_docs_url) unless is_route_id? route_id
              halt 400, bad_url_error(bad_route_message) unless is_route_id? route_id
              wrapRequest(api_root + "&command=vehicleLocations&r=#{route_id}")
            end

            # locations of all buses
            get '/locations' do
              cache_control :public, :must_revalidate, max_age: 60

              wrapRequest(api_root + '&command=vehicleLocations')
            end

            # list the bus stops
            get '/stops' do
              json Stop.all.map(&:to_v1_info)
            end

            # get info about a particular bus stop
            get '/stops/:stop_id' do
              stop_id = params[:stop_id]
              halt 400, bad_url_error(bad_stop_message, bus_docs_url) unless is_stop_id? stop_id
              json Stop.where(stop_id: stop_id).map(&:to_v1)
            end
          end

          # this should probably be a more specific error message where we error out!
          bad_route_message = "umd.io doesn't know the bus route in your url. Full list at https://api.umd.io/v0/bus/routes"
          bad_stop_message = "umd.io doesn't know the stop in your url. Full list at https://api.umd.io/v0/bus/routes"
          bus_docs_url = 'https://docs.umd.io/bus'
          api_root = 'https://retro.umoiq.com/service/publicJSONFeed?a=umd'
          require 'net/http'

          # root of bus endpoint
          app.get '/v0/bus' do
            resp = {
              message: 'This is the bus endpoint.',
              status: 'working (we think!)',
              docs: 'https://docs.umd.io/bus/'
            }
            json resp
          end

          # lists bus routes
          app.get '/v0/bus/routes' do
            json Route.all.map(&:to_v0_info)
          end

          # get info about one or more routes
          # in nextbus api terms, this is routeConfig - the info for a route
          app.get '/v0/bus/routes/:route_id' do
            route_ids = params[:route_id].downcase.split(',')
            route_ids.each do |route_id|
              halt 400, bad_url_error(bad_route_message, bus_docs_url) unless is_route_id? route_id
            end
            routes = Route.where(route_id: route_ids).map(&:to_v0)
            # get rid of [] on single object return
            routes = routes[0] if route_ids.length == 1
            # prevent null being returned
            # Never gets hit, because we are checking a hard-coded list of routes.
            # We should be consistent in how we do this instead of this haphazard approach...
            routes ||= {}
            json routes
          end

          # schedules for a route
          # schedules are updated along with routes every semester or so
          app.get '/v0/bus/routes/:route_id/schedules' do
            cache_control :public, :must_revalidate, max_age: 60 * 60

            route_id = params[:route_id]
            halt 400, bad_url_error(bad_route_message, bus_docs_url) unless is_route_id? route_id
            json Schedule.where(route: route_id).map(&:to_v0)
          end

          # next arriving buses for a particular stop on the route (in nextbus, the predictions)
          # Not sure how/whether to set this one up for polling & adding to the database. leaving it for now
          app.get '/v0/bus/routes/:route_id/arrivals/:stop_id' do
            cache_control :public, :must_revalidate, max_age: 60

            route_id = params[:route_id]
            stop_id = params[:stop_id]

            halt 400, bad_url_error(bad_route_message, bus_docs_url) unless is_route_id? route_id
            halt 400, bad_url_error(bad_stop_message, bus_docs_url) unless is_stop_id? stop_id
            wrapRequest(api_root + "&command=predictions&r=#{route_id}&s=#{stop_id}")
          end

          # locations of buses on route
          app.get '/v0/bus/routes/:route_id/locations' do
            cache_control :public, :must_revalidate, :no_cache, max_age: 60

            route_id = params[:route_id]

            halt 400, bad_url_error(bad_route_message, bus_docs_url) unless is_route_id? route_id
            halt 400, bad_url_error(bad_route_message) unless is_route_id? route_id
            wrapRequest(api_root + "&command=vehicleLocations&r=#{route_id}")
          end

          # locations of all buses
          app.get '/v0/bus/locations' do
            cache_control :public, :must_revalidate, max_age: 60

            wrapRequest(api_root + '&command=vehicleLocations')
          end

          # list the bus stops
          app.get '/v0/bus/stops' do
            json Stop.all.map(&:to_v0_info)
          end

          # get info about a particular bus stop
          app.get '/v0/bus/stops/:stop_id' do
            stop_id = params[:stop_id]
            halt 400, bad_url_error(bad_stop_message, bus_docs_url) unless is_stop_id? stop_id
            json Stop.where(stop_id: stop_id).map(&:to_v0)
          end
        end
      end
    end
  end
end
