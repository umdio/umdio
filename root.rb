# Module for the root route and a catch-all error route
module Sinatra
  module UMDIO
    module Routing
      module Root

        def self.registered(app)
          # base url, returns a list of available endpoints (and shold point to docs)
          app.get '/' do
            resp = {
              message: "This is the umd.io JSON API.",
              status: "working, most of the time",
              docs: "http://umd.io/",
              current_version: "v0",
              versions: [
                {
                  id: "v0",
                  url: "https://api.umd.io/v0"
                }
              ],
            }
            json resp
          end

          app.get '/v0' do
            resp = {
              id: "v0",
              version: "0.0.1",
              name: "naming convention?",
              endpoints: [
                {
                  name: 'Courses',
                  url: 'https://api.umd.io/v0/courses',
                  docs: 'http://umd.io/courses/'
                },
                {
                  name: 'Bus',
                  url: 'https://api.umd.io/v0/bus',
                  docs: 'http://umd.io/bus/'
                },
                {
                  name: 'Map',
                  url: 'https://api.umd.io/v0/map',
                  docs: 'http://umd.io/map/'
                },
              ]
            }
            json resp
          end

          app.get '/*' do
            resp = {
              error_code: 404,
              message: "We couldn't find what you're looking for. Please see the docs for more information.",
              docs: "http://umd.io/"
            }
            status 404
            json resp
          end

        end
      end
    end
  end
end
