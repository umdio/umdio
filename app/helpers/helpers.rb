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
        params['page'] = (@count.count.to_f / @limit).ceil.to_i
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
      headers['X-Total-Count'] = @count
    end

    def params_sorting_array default=''
      sorting = []
      params['sort'] ||= default
      params['sort'].split(',').each do |sort|
        order_str = '+'
        if sort[0] == '+' or sort[0] == '-'
          order_str = sort[0]
          sort = sort[1..sort.length]
        end
        order = (order_str == '+' ? 1 : -1)
        sorting << sort
        sorting << order
      end unless params['sort'].empty?

      return sorting
    end

    def params_search_query db, ignore=nil
      # Sinatra adds this param in some cases, and we don't want it
      # TODO: Is there a better way we can delete this?
      params.delete(:captures) if params.key?(:captures)

      query = []
      params.keys.each do |key| unless ignore.include?(key)
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
          query << db::escape_string(parts[0]) + delim + db::escape_string(parts[1])
        elsif key.include? ('!')
          # Delete !
          parts = key.split('!')

          # Now look at the other side of the !=
          if params[key].include? (',') or params[key].include? ('|')
            delim = (params[key].include?(',') ? ',' : '|')
            query[parts[0]] = { "$nin" => params[key].split(delim) }
          else
            query << db::escape_string(parts[0]) + "!=" + db::escape_string(params[key])
          end
        elsif not params[key].nil?
          if params[key].include? (',')
            query[key] = { "$in" => params[key].split(',') }
          elsif params[key].include? ('|')
            query[key] = { "$all" => params[key].split('|') }
          else
            query[key] = params[key]
          end
        end
      end
      end

      return query
    end
  end
end
end
