require_relative '../models/majors.rb'

module Sinatra
  module UMDIO
    module Routing
      module Majors
        def self.registered(app)
          majors_t = majors_table(app.settings.DB)

          app.before do
            content_type 'application/json'
          end

          # Route for majors
          app.get '/v0/majors' do
            majors = majors_t.all
            majors.each do |e|
              e.delete(:pid)
            end

            json majors
          end
        end
      end
    end
  end
end