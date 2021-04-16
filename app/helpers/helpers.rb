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

    def fix_sem
      if !params['semester']
        request.update_param('semester', current_semester)
      end
      check_semester app, request.params['semester']
    end

    def rename_param from, to
      if request.params[from]
        request.update_param(to, request[from])
        request.delete_param(from)
      end
    end

    def upper_param name
      if request.params[name]
        request.update_param(name, request.params[name].upcase)
      end
    end

    def parse_delim d
      vals = {
        eq: "=",
        neq: "!=",
        lt: "<",
        gt: ">",
        leq: "<=",
        geq: ">="
      }

      halt 400, { error_code: 400, message: "Malformed parameters" }.to_json if (!vals.key? d)

      vals[d]
    end

    def standardize_params_v1
      std_params = {}

      request.params.keys.each do |key|
        value = request.params[key]

        v = ""
        d = ""
        if value.to_s.include? "|"
          x = value.split("|")
          v = x[0]
          d = parse_delim x[1].to_sym
        else
          v = value
          d = "="
        end

        std_params[key] = [v, d]
      end

      std_params
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

        if value.is_a? String
          value = value.squeeze(' ')
        end
        std_params[key] = [value, delim]
      end

      std_params
    end

    # Uses a whitelist of request.params to parse
    def parse_query_v0 valid_params
      conds = []

      std_params = standardize_params
      std_params.keys.each do |key| if (valid_params.include? key)
        value = std_params[key][0]
        delim = std_params[key][1]

        if delim.include? '!'
          conds << Sequel.~(Sequel.lit("#{key} #{delim} ?", value))
        else
          conds << Sequel.lit("#{key} #{delim} ?", value)
        end
      end
    end
    conds
  end

  def parse_query_v1 valid_params
      conds = []

      std_params = standardize_params_v1
      std_params.keys.each do |key| if (valid_params.include? key)
        value = std_params[key][0]
        delim = std_params[key][1]

        if key == "gen_ed"
          if delim.include? '!'
            conds << Sequel.~(Sequel.lit("#{key} LIKE ?", "%#{value}%"))
          else
            conds << Sequel.lit("#{key} LIKE ?", "%#{value}%")
          end
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
