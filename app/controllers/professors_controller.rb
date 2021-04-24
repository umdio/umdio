# Module for Professor endpoint

module Sinatra
  module UMDIO
    module Routing
      module Professors
        def self.registered(app)
          app.register Sinatra::Namespace

          app.namespace '/v1/professors' do
            before '*' do
              @special_params = %w[sort per_page page]
              @section_params = %w[semester course_id]
              @prof_params = ['name']

              rename_param 'course', 'course_id'
              rename_param 'courses', 'course_id'

              upper_param 'course_id'
            end

            get do
              begin_paginate! $DB[:professors]

              sorting = parse_sorting_params 'name'

              # v1 currently has a bug for double places
              std_params = parse_query_v0 @prof_params
              section_std_params = parse_query_v0 @section_params

              if (std_params == []) && (section_std_params == [])
                res = Professor.order(*sorting)
                               .limit(@limit)
                               .offset((@page - 1) * @limit)
                               .map { |p| p.to_v1 }

                return json res
              end

              y = Section.where { Sequel.&(*section_std_params) } unless section_std_params == []
              y = Section.all if section_std_params == []

              x = Sequel.&(*std_params, sections: y) unless std_params == []
              x = { sections: y } if std_params == []

              res =
                Professor
                .where(x)
                .order(*sorting)
                .limit(@limit)
                .offset((@page - 1) * @limit)
                .map { |p| p.to_v1 }

              end_paginate! res

              # If no professors found, 404
              if res == []
                halt 404, not_found_error('There were no professors that matched your search.', 'https://docs.umd.io/#tag/professors')
              end

              json res
            end
          end

          app.before '/v0/professors*' do
            @special_params = %w[sort semester per_page page]
            @section_params = %w[semester course_id dept_id]
            @prof_params = ['name']

            rename_param 'courses', 'course_id'
            rename_param 'departments', 'dept_id'

            upper_param 'course_id'
            upper_param 'dept_id'

            fix_sem
          end

          # Route for professors, use 'name' or 'course' to filter
          app.get '/v0/professors' do
            begin_paginate! $DB[:professors]

            sorting = parse_sorting_params 'name'
            std_params = parse_query_v0 @prof_params

            section_std_params = parse_query_v0 @section_params

            res =
              Professor
              .where(Sequel.&(*std_params, sections: Section.where { Sequel.&(*section_std_params) }))
              .order(*sorting)
              .limit(@limit)
              .offset((@page - 1) * @limit)
              .map { |p| p.to_v0 }

            end_paginate! res

            # Throw a 404 if prof is empty. (Doesn't exist or invalid)
            if res == []
              halt 404, {
                error_code: 404,
                message: 'There were no professors that matched your search.',
                docs: 'https://docs.umd.io/professors'
              }.to_json
            end

            json res
          end
        end
      end
    end
  end
end
