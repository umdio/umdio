# Module for Majors endpoint

module Sinatra
  module UMDIO
    module Routing
      module Majors

        def self.registered(app)
          majors_collection = app.settings.majors_db.collection('majors')

          app.before do
            content_type 'application/json'
          end

          # Route for majors
          app.get '/v0/majors' do
            json majors_collection.find({},{fields: {:_id => 0}}).map { |e| e }
          end

        end

      end
    end
  end
end