require 'net/http'
require 'json'

##
# Provides UMD bus data using the [UMO API](https://retro.umoiq.com/xmlFeedDocs/NextBusXMLFeed.pdf).
#
# @see https://retro.umoiq.com/xmlFeedDocs/NextBusXMLFeed.pdf
module UMO
  @agency = 'umd'

  ##
  # Gets a list of bus routes.
  #
  # The route list data returned has multiple attributes. These are:
  # * tag – unique alphanumeric identifier for route, such as “N”.
  # * title – the name of the route to be displayed in a User Interface, such as “N-Judah”.
  # * shortTitle – for some transit agencies shorter titles are provided that can be useful for
  #
  # User Interfaces where there is not much screen real estate, such as on smartphones.
  # This element is only provided where a short title is actually available. If a short title is
  # not available then the regular title element should be used.
  #
  # @return [Array<Hash>] a list of bus routes.
  def self.get_routes
    res = api command: 'routeList'
    routes = res['route']
    routes.each do |r|
      r['shortTitle'] = nil unless r.key? 'shortTitle'
    end
  end

  ##
  # @return [Array<Hash>] a list of bus route configs.
  def self.list_route_configs()
    # query_params = { command: 'routeConfig', a: @agency }
    # query_params[:r] = route if route
    res = api command: 'routeConfig', a: @agency
    routes = res['route']
    routes.each do |route|
      route['shortTitle'] = nil unless route.key? 'shortTitle'
      route['latMin'] = route['latMin'].to_f
      route['latMax'] = route['latMax'].to_f
      route['lonMin'] = route['lonMin'].to_f
      route['lonMax'] = route['lonMax'].to_f

      # Clean up stop list
      route['stop'].each do |stop|
        stop['lat'] = stop['lat'].to_f
        stop['lon'] = stop['lon'].to_f
        stop['shortTitle'] = nil unless stop.key? 'shortTitle'
        stop['stopId'] = stop['stopId'].to_i
      end

      # Clean up direction list
      route['direction'] = [route['direction']] unless route['direction'].is_a? Array
      route['direction'].each do |direction|
        next if direction['stop'].is_a? Array

        direction['stop'] = if direction['stop'].nil?
                              []
                            else [direction['stop']]
                            end

        # route['stop'] = [route] unless
      end

      # Clean up path list
      route['path'] ||= []
      route['path'].each do |path|
        path['point'].each do |point|
          point['lat'] = point['lat'].to_f
          point['lon'] = point['lon'].to_f
        end
      end
    end
  end

  ##
  # @return [Hash] a bus route config for a single route
  def self.get_route_config(route)
    raise TypeError, 'route cannot be nil' if route.nil?
    route = route.to_s if route.is_a? Symbol or route.is_a? Integer
    raise TypeError, "route #{route} is not a valid route" unless route.is_a? String

    res = api command: 'routeConfig', a: @agency, r: route
    route = res['route']

    route['shortTitle'] = nil unless route.key? 'shortTitle'
    route['latMin'] = route['latMin'].to_f
    route['latMax'] = route['latMax'].to_f
    route['lonMin'] = route['lonMin'].to_f
    route['lonMax'] = route['lonMax'].to_f

    # Clean up stop list
    route['stop'].each do |stop|
      stop['lat'] = stop['lat'].to_f
      stop['lon'] = stop['lon'].to_f
      stop['shortTitle'] = nil unless stop.key? 'shortTitle'
      stop['stopId'] = stop['stopId'].to_i
    end

    # Clean up direction list
    route['direction'] = [route['direction']] unless route['direction'].is_a? Array
    route['direction'].each do |direction|
      next if direction['stop'].is_a? Array

      direction['stop'] = if direction['stop'].nil?
                            []
                          else [direction['stop']]
                          end

      # route['stop'] = [route] unless
    end

    # Clean up path list
    route['path'] ||= []
    route['path'].each do |path|
      path['point'].each do |point|
        point['lat'] = point['lat'].to_f
        point['lon'] = point['lon'].to_f
      end
    end

    route
  end

  ##
  # @return [Array<Hash>] a list of bus schedules.
  def self.get_schedule(route)
    raise ArgumentError, 'No bus route provided' if route.nil?

    route = route.to_s if route.is_a? Integer
    raise ArgumentError, 'Invalid bus route' unless route.is_a? String

    res = api command: 'schedule', r: route
    routes = res['route']

    routes.each do |route|
      stop = route['header']['stop']
      route['header']['stop'] = [stop] unless stop.is_a? Array


      route['tr'].each do |block|
        block['blockID'] = block['blockID'].to_i

        block['stop'] = [block['stop']] unless block['stop'].is_a? Array
        block['stop'].each do |block_stop|
          raise "Block stop #{block_stop} is not a hash"  unless block_stop.is_a? Hash
          block_stop['epochTime'] = block_stop['epochTime'].to_i
        end
      end
    end

    routes
  end

  ##
  # Builds a request url.
  #
  # @param [Hash] query params to include in the url. Must at least include a `:command`.
  # @return [URI] the url
  #
  def self.url(query_params = {})
    raise 'Missing :command query parameter' unless query_params[:command]

    url = URI('https://retro.umoiq.com/service/publicJSONFeed')
    query_params[:a] = @agency unless query_params[:a]
    url.query = URI.encode_www_form(query_params)

    url
  end

  ##
  # Makes an API request.
  #
  # @see #url
  #
  # @param [Hash] query params to include in the url. Must at least include a `:command`.
  #
  # @return [Hash] the parsed API response
  #
  def self.api(query_params = {})
    # raise NoMethodError, "Invalid HTTP method #{method}" unless Net::HTTP.respond_to?(method)
    _url = url(query_params)

    # @type [Net::HTTPResponse]
    res = Net::HTTP.get_response(_url)
    # res.code = res.code.to_i unless res.code.nil?
    raise Net::HTTPError, res.code if res.code.to_i >= 400

    # raise Net::HTTPError

    JSON.parse(res.body)
  end
end
