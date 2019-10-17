# Module for Professor endpoint

module Sinatra
  module UMDIO
    module Routing
      module Professors
        def self.registered(app)
          app.register Sinatra::Namespace

          app.namespace '/v1/professors' do
            app.before do
              @special_params = ['sort', 'semester', 'per_page', 'page']
              @prof_params = ['name']
              @prof_array_params = ['semester', 'courses', 'dept']

              fix_sem
            end

            get do
              begin_paginate! $DB[:professors]

            sorting = parse_sorting_params 'name'
            std_params = parse_query_v0 @prof_params, @prof_array_params

            res =
              Professor
                .where{Sequel.&(*std_params)}
                .order(*sorting)
                .limit(@limit)
                .offset((@page - 1)*@limit)
                .map{|p| p.to_v0}

            end_paginate! res

            #Throw a 404 if prof is empty. (Doesn't exist or invalid)
            if res == []
              halt 404, {
                error_code: 404,
                message: "There were no professors that matched your search.",
                docs: "https://docs.umd.io/professors"
              }.to_json
            end

            json res
            end
          end


          app.before '/v0/professors*' do
            @special_params = ['sort', 'semester', 'per_page', 'page']
            @prof_params = ['name']
            @prof_array_params = ['semester', 'courses', 'dept']

            fix_sem
          end

          # Route for professors, use 'name' or 'course' to filter
          app.get '/v0/professors' do
            begin_paginate! $DB[:professors]

            sorting = parse_sorting_params 'name'
            std_params = parse_query_v0 @prof_params, @prof_array_params

            res =
              Professor
                .where{Sequel.&(*std_params)}
                .order(*sorting)
                .limit(@limit)
                .offset((@page - 1)*@limit)
                .map{|p| p.to_v0}

            end_paginate! res

            #Throw a 404 if prof is empty. (Doesn't exist or invalid)
            if res == []
              halt 404, {
                error_code: 404,
                message: "There were no professors that matched your search.",
                docs: "https://docs.umd.io/professors"
              }.to_json
            end

            json res
          end
        end
      end
    end
  end
end