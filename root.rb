# Module for the root route and a catch-all error route
# TODO: use URL re-writing to remove trailing slashes (301)
module Sinatra
  module UMDIO
    module Routing
      module Root

        def self.registered(app)
          # base url, returns a list of available endpoints (and shold point to docs)
          app.get '/' do
            resp = {
              message: "This is the umd.io JSON API.",
              status: "kinda working",
              docs: "http://umd.io/docs/",
              current_version: "v0",
              versions: [
                {
                  id: "v0",
                  url: "http://api.umd.io/v0"
                }
              ],
            }
            json resp
          end

          app.get '/v0' do
            resp = {
              id: "v0",
              version: "0.0.1",
              name: "Some naming convention here",
              endpoints: [
                {
                  name: 'Courses',
                  url: 'http://api.umd.io/v0/courses',
                  docs: 'http://umd.io/docs/courses'
                }
              ]
            }
            json resp
          end

          app.get '/*' do
            resp = {
              error_code: 404,
              message: "We couldn't find what you're looking for. Please see the docs for more information.",
              docs: "http://umd.io/docs/"
            }
            json resp
          end

        end
      end
    end
  end
end
