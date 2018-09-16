# Module for Professor endpoint

module Sinatra
  module UMDIO
    module Routing
      module Professors

        def self.registered(app)

          app.before '/v0/professors*' do
            @special_params = ['sort', 'semester', 'per_page', 'page']

            semester = params[:semester] || current_semester
            check_semester app, semester, 'profs'

            @prof_coll = app.settings.courses_db.collection("profs#{semester}")
          end

          # Route for professors, use 'name' or 'course' to filter
          app.get '/v0/professors' do
            begin_paginate! @prof_coll 
            
            query = params_search_query @special_params
            sorting = params_sorting_array "name"
            
            profs = @prof_coll.find(query, { :sort => sorting, :limit => @limit, :skip => (@page - 1)*@limit, :fields => { :_id => 0 } }).map { |e| e }
            
            end_paginate! profs

            #Throw a 404 if prof is empty. (Doesn't exist or invalid)
            if profs == []
              halt 404, {
                error_code: 404, 
                message: "Professor isn't in our database, and probably doesn't exist.",
                docs: "https://umd.io/professors"
              }.to_json
            end

            json profs
          end
        end
      end
    end
  end
end