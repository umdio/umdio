# Module for Professor endpoint

module Sinatra
  module UMDIO
    module Routing
      module Professors

        def self.registered(app)

          app.before '/v0/professors*' do
            @special_params = ['sort', 'semester', 'per_page', 'page']

            params[:semester] ||= current_semester
            check_semester app, params[:semester], 'courses'

            @db = app.settings.postgres
          end

          # Route for professors, use 'name' or 'course' to filter
          app.get '/v0/professors' do
            begin_paginate! @db, "professors"

            query = params_search_query @db, @special_params
            sorting = params_sorting_array "name"

            if query == ''
              query = 'TRUE'
            end

            offset = (@page - 1)*@limit
            limit = @limit

            query.chomp! "AND "
            query += " AND EXISTS(SELECT 1 FROM professors JOIN section_professors ON professors.id=section_professors.professor_id JOIN sections ON section_professors.section = sections.id WHERE sections.semester=#{current_semester} AND professors.id = p.id)"

            profs = []
            res = @db.exec("SELECT * FROM professors as p WHERE #{query} ORDER BY #{sorting} LIMIT #{limit} OFFSET #{offset}")

            res.each do |row|
              profs << clean_professor(@db, (params[:semester] || current_semester), row)
            end

            end_paginate! profs

            #Throw a 404 if prof is empty. (Doesn't exist or invalid)
            if profs == []
              halt 404, {
                error_code: 404,
                message: "There were no professors that matched your search.",
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