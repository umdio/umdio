module Sinatra
  module UMDIO
    module Routing
      module Majors
        def self.registered(app)
          app.register Sinatra::Namespace

          app.namespace '/v1/majors' do
            get do
              resp = {
                message: 'This is the majors endpoint.',
                version: '1.0.0',
                docs: 'https://beta.umd.io/majors',
                endpoints: ['/list']
              }
              json resp
            end

            get '/list' do
              json Major.all.map { |m| m.to_v1 }.uniq
            end
          end

          app.namespace '/v0/majors' do
            get do
              json Major.all.map { |m| m.to_v0 }.uniq
            end
          end
        end
      end
    end
  end
end
