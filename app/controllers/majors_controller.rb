require_relative '../models/majors.rb'

module Sinatra
  module UMDIO
    module Routing
      module Majors
        def self.registered(app)
          app.before do
            content_type 'application/json'
          end

          # Route for majors
          app.get '/v0/majors' do
            json Major.all.map {|m| m.to_v0}
          end
        end
      end
    end
  end
end