# general helper methods for controllers
module Sinatra
module UMDIO
  module Helpers
    # adds instance variables to start the pagitaion based on request.params['page'] and request.params['per_page']
    # the following instance variables are reserved: collection, limit, page, next_page, and prev_page
    def begin_paginate! data, default_per_page=30, max_per_page=100
      @data = data
      # clamp page and per_page request.params
      request.params['page'] = (request.params['page'] || 1).to_i
      request.params['page'] = 1 if request.params['page'] < 1

      request.params['per_page'] = (request.params['per_page'] || default_per_page).to_i
      request.params['per_page'] = max_per_page if request.params['per_page'] > max_per_page
      request.params['per_page'] = 1 if request.params['per_page'] < 1

      @limit = request.params['per_page']
      @page  = request.params['page']

      # create the next & prev page links
      path = request.fullpath.split('?')[0]
      base = base_url + path + '?'

      # next page
      request.params['page'] += 1
      @next_page = base + request.params.map{|k,v| "#{k}=#{v}"}.join('&')

      @count = @data.count

      # prev page
      request.params['page'] -= 2
      if (request.params['page']*@limit > @count)
        request.params['page'] = (@count.to_f / @limit).ceil.to_i
      end
      @prev_page = base + request.params.map{|k,v| "#{k}=#{v}"}.join('&')
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

    def parse_sorting_params default=''
      request.params['sort'] ||= default

      if request.params['sort'] == ''
        return [Sequel.asc(:pid)]
      end

      sorting = []
      request.params['sort'].split(',').each do |sort|
        order_str = '+'
        if sort[0] == '+' or sort[0] == '-'
          order_str = sort[0]
          sort = sort[1..sort.length]
        end

        if order_str == "+"
          sorting << Sequel.asc(sort.to_sym)
        else
          sorting << Sequel.desc(sort.to_sym)
        end
      end

      sorting
    end

    # Turn request.params into a reasonable format
    def standardize_params
      std_params = {}

      request.params.keys.each do |key|
        value = request.params[key]
        key = key.to_s

        if key.include? ('<') or key.include? ('>')
          delim = (key.include? ('<')) ? '<' : '>'

          # Check for =
          parts = key.split(delim)
          if parts.length == 1
            key = parts[0]
            delim += '='
          else
            key = parts[0]
            value = parts[1]
          end
        elsif key.include? ('!')
          key = key.split('!')[0]
          delim = '!='
        elsif not value.nil?
          delim = '='
        else
          halt 400, { error_code: 400, message: "Malformed parameters" }.to_json
        end
        std_params[key] = [value, delim]
      end

      std_params
    end

    # Uses a whitelist of request.params to parse
    def parse_query_v0 valid_params, valid_array_params=[], valid_json_array_params=[]
      conds = []

      std_params = standardize_params
      std_params.keys.each do |key| if (valid_params.include? key) or (valid_array_params.include? key) or (valid_json_array_params.include? key)
        value = std_params[key][0]
        delim = std_params[key][1]

        if valid_array_params.include? key
          j = Sequel.pg_jsonb_op(key.to_sym)

          if value.include? ','
            conds << j.contain_any(value.split(','))
          else
            conds << j.contain_all(value.split('|'))
          end
        elsif valid_json_array_params.include? key
          key_parts = key.split('.')
          nkey = key_parts[1]

          conds << {section_key: $DB[key_parts[0].to_sym].where(Sequel.lit("#{key} #{delim} ?", value)).map{|m| m[:section_key]}}
        else
          if delim.include? '!'
            conds << Sequel.~(Sequel.lit("#{key} #{delim} ?", value))
          else
            conds << Sequel.lit("#{key} #{delim} ?", value)
          end
        end
      end
    end
    conds
  end
end
end
end