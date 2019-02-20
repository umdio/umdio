# general helper methods for controllers
module Sinatra
module UMDIO
  module Helpers
    # adds instance variables to start the pagitaion based on params['page'] and params['per_page']
    # the following instance variables are reserved: collection, limit, page, next_page, and prev_page
    def begin_paginate! db, table, default_per_page=30, max_per_page=100
      @db = db
      @table = table
      # clamp page and per_page params
      params['page'] = (params['page'] || 1).to_i
      params['page'] = 1 if params['page'] < 1

      params['per_page'] = (params['per_page'] || default_per_page).to_i
      params['per_page'] = max_per_page if params['per_page'] > max_per_page
      params['per_page'] = 1 if params['per_page'] < 1

      @limit = params['per_page']
      @page  = params['page']

      # create the next & prev page links
      path = request.fullpath.split('?')[0]
      base = base_url + path + '?'

      # next page
      params['page'] += 1
      @next_page = base + params.map{|k,v| "#{k}=#{v}"}.join('&')

      @count = @db.exec("SELECT COUNT(*) FROM #{@table}").first.count

      # prev page
      params['page'] -= 2
      if (params['page']*@limit > @count)
        params['page'] = (@count.to_f / @limit).ceil.to_i
      end
      @prev_page = base + params.map{|k,v| "#{k}=#{v}"}.join('&')
    end

    # sets the response headers Link and X-Total-Count based on the results
    def end_paginate! results
      # set the link headers
      link = ""
      link += "<#{@next_page}>; rel=\"next\"" unless results.empty? or results.count < @limit
      headers['X-Next-Page'] = @next_page unless results.empty? or results.count < @limit
      if not results.empty? and @page > 1
        link += ", "
      end
      link += "<#{@prev_page}>; rel=\"prev\"" unless @page == 1
      headers['X-Prev-Page'] = @prev_page unless @page == 1
      headers['Link'] = link
      headers['X-Total-Count'] = @count.to_s
    end

    def params_sorting_array default=''
      params['sort'] ||= default

      if params['sort'] == ''
        return "id ASC"
      end

      sort_query = ""
      params['sort'].split(',').each do |sort|
        # Figure out what order, and strip it from the field name
        order_str = '+'
        if sort[0] == '+' or sort[0] == '-'
          order_str = sort[0]
          sort = sort[1..sort.length]
        end

        # Turn that into a postgres ORDER BY clause
        order = (order_str == '+' ? "ASC" : "DESC")
        sort_query += "#{sort} #{order},"
      end

      return sort_query.chomp(',')
    end

    def params_search_query db, ignore=nil
      # Sinatra adds this param in some cases, and we don't want it
      # TODO: Is there a better way we can delete this?
      params.delete(:captures) if params.key?(:captures)

      # What params need to be represented as arrays
      arr_params = ['gen_ed', 'grading_method', 'instructors']

      query = ''
      # TODO: Error on =''
      params.keys.each do |key| unless ignore.include?(key) or params[key] == ''
        if key.include? ('<') or key.include? ('>')
          # Check which delim
          delim = (key.include? ('<')) ? '<' : '>'

          # Check for =
          parts = key.split(delim)
          if parts.length == 1
            parts[1] = params[key]
            delim += '='
          end

          # Build sql
          query += db::escape_string(parts[0]) + delim +  "'" +db::escape_string(parts[1]) +  "'"
        elsif key.include? ('!')
          # Delete !
          parts = key.split('!')

          # Now look at the other side of the !=
          if params[key].include? (',') or params[key].include? ('|') or arr_params.include? key
            delim = params[key].include?(',') ? ',' : '|'
            op = params[key].include?(',') ? '&&' : '@>'

            # TODO: injection?
            query += "NOT (" + db::escape_string(parts[0]) + op + "ARRAY[#{params[key].split(delim).join(',')}])"
          else
            query += db::escape_string(parts[0]) + "!=" +  "'" + db::escape_string(params[key]) +  "'"
          end
        elsif not params[key].nil?
          l = params[key].split(',').length
          # Array Search
          if params[key].include? (',') or (arr_params.include? key and l == 1)
            query += db::escape_string(key) + "&&" + "ARRAY['#{params[key].split(',').join("','")}']"
          elsif params[key].include? ('|')
            query += db::escape_string(key) + "@>" + "ARRAY['#{params[key].split('|').join("','")}']"
          else
            query += db::escape_string(key) + "=" + "'" + db::escape_string(params[key]) + "'"
          end
        end
        query += " AND "
      end

      end

      return query.chomp("AND ")
    end
  end
end
end
