# Module for Professor endpoint

module Sinatra
  module UMDIO
    module Routing
      module Professors

      	# make sure database 'umdprof' exists!!
        def self.registered(app)

          app.before '/v0/professors*' do
            @special_params = ['sort', 'semester', 'per_page', 'page']

            # TODO: don't hardcode this
            params[:semester] ||= '201608'

            # check for semester formatting
            if not (params[:semester].length == 6 and params[:semester].is_number?)
              halt 400, { error_code: 400, message: "Invalid semester parameter! semester must be 6 digits" }.to_json
			      end

            # check if we have data for the requested semester
            collection_names = app.settings.courses_db.collection_names()
            if not collection_names.index("courses#{params[:semester]}")
              semesters = collection_names.select { |e| e.start_with? "courses" }.map{ |e| e.slice(7,6) }
              msg = "We don't have data for this semester! If you leave off the semester parameter, we'll give you the courses currently on Testudo. Or try one of the available semester below:"
              halt 404, {error_code: 404, message: msg, semesters: semesters}.to_json
            end

            # @prof_coll = app.settings.profs_db.collection("profs#{params[:semester]}")
            @prof_coll = app.settings.courses_db.collection("profs#{params[:semester]}")
          end

          # Route for professors, use 'name' or 'course' to filter
          app.get '/v0/professors' do
            begin_paginate! @prof_coll 
            
            query = params_search_query @special_params
            sorting = params_sorting_array "name"

            
            profs = @prof_coll.find(query, { :sort => sorting, :limit => @limit, :skip => (@page - 1)*@limit, :fields => { :_id => 0 } }).map { |e| e }
            
            end_paginate! profs

            json profs
          end
        end
      end
    end
  end
end