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
              docs: "https://docs.umd.io/",
              current_version: "v0",
              versions: [
                {
                  id: "v1",
                  url: "https://api.umd.io/v1"
                },
                {
                  id: "v0",
                  url: "https://api.umd.io/v0"
                }
              ],
            }
            json resp
          end

          app.get '/v1' do
            resp = {
              id: "v1",
              version: "1.0.0",
              endpoints: [
                {
                  name: 'Courses',
                  url: 'https://api.umd.io/v1/courses',
                  docs: 'https://docs.umd.io/#tag/courses'
                },
                {
                  name: 'Professors',
                  url: 'https://api.umd.io/v1/professors',
                  docs: 'https://docs.umd.io/#tag/professors'
                },
                {
                  name: 'Bus',
                  url: 'https://api.umd.io/v1/bus',
                  docs: 'https://docs.umd.io/#tag/bus'
                },
                {
                  name: 'Map',
                  url: 'https://api.umd.io/v1/map',
                  docs: 'https://docs.umd.io/#tag/map'
                },
                {
                  name: 'Majors',
                  url: 'https://api.umd.io/v1/majors',
                  docs: 'https://docs.umd.io/#tag/majors'
                },
              ]
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
                  docs: 'https://docs.umd.io/courses/'
                },
                {
                  name: 'Bus',
                  url: 'https://api.umd.io/v0/bus',
                  docs: 'https://docs.umd.io/bus/'
                },
                {
                  name: 'Map',
                  url: 'https://api.umd.io/v0/map',
                  docs: 'https://docs.umd.io/map/'
                },
              ]
            }
            json resp
          end

          app.get '/v1/spec.yaml' do
            headers['Access-Control-Allow-Origin'] = '*'
            File.read('openapi.yaml')
          end

          app.get '/*' do
            resp = {
              error_code: 404,
              message: "We couldn't find what you're looking for. Please see the docs for more information.",
              docs: "https://docs.umd.io/"
            }
            status 404
            json resp
          end

        end
      end
    end
  end
end
