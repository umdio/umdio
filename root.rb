#Module for the root route and a catch-all error route

module Sinatra
  module UMDIO
    module Routing
      module Root

        def self.registered(app)
          status = 'kinda working'

              #base url, returns a list of available endpoints (and shold point to docs)
          app.get '/' do
            "This is the umd.io JSON api. (currently #{status}) <br>
              We'll tell you more about the available endpoints when there are real docs!<br>
            "
          end

          #should actually give a JSON formatted error
          app.get '/*' do
            path = params[:splat].first
            "You lost? <br>
              You came from #{if(path.length > 0) then path + ", which doesn't seem to be a real place yet." else "/" end} <br>
            "
          end
        end
  
      end
    end
  end
end