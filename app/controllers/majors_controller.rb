module Sinatra
  module UMDIO
    module Routing
      module Majors
        def self.registered(app)
          app.get '/v0/majors' do
            json Major.all.map {|m| m.to_v0}
          end
        end
      end
    end
  end
end