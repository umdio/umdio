# general helper methods for controllers
module Sinatra
module UMDIO
  module Helpers
    # adds instance variables to start the pagitaion based on params['page'] and params['per_page']
    # the following instance variables are reserved: collection, limit, page, next_page, and prev_page
    # @param Mongo::Collection collection the collection to paginate on
    def begin_paginate! collection, default_per_page=30, max_per_page=100
      @collection = collection
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

      # prev page
      params['page'] -= 2
      if (params['page']*@limit > collection.count)
        params['page'] = (collection.count.to_f / limit).ceil.to_i
      end
      @prev_page = base + params.map{|k,v| "#{k}=#{v}"}.join('&')
    end

    # sets the response headers Link and X-Total-Count based on the results
    # @param Mongo::CollectionView results
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
      headers['X-Total-Count'] = @collection.count.to_s
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

    def params_search_query ignore=nil
      query = {}
      params.keys.each do |k| unless ignore.include?(k)
        e = ''
        if k.include? ('<') or k.include? ('>')
          delim = ((k.include? ('<')) ? '<' : '>')
          cmp   = ((delim ==    '<')  ? 'l' : 'g')
          parts = k.split(delim)
          if parts.length == 1
            parts[1] = params[k]
            e = 'e'
          end
          query[parts[0]] = { "$#{cmp}t#{e}" => parts[1] }
        elsif k.include? ('!')
          parts = k.split('!')
          if params[k].include? (',') or params[k].include? ('|')
            delim = (params[k].include?(',') ? ',' : '|')
            query[parts[0]] = { "$nin" => params[k].split(delim) }
          else
            query[parts[0]] = { "$ne" => params[k] }
          end
        elsif not params[k].nil?
          if params[k].include? (',')
            query[k] = { "$in" => params[k].split(',') }
          elsif params[k].include? ('|')
            query[k] = { "$all" => params[k].split('|') }
          else
            query[k] = params[k]
          end
        end
      end
      end

      return query
    end
  end
end
end
