require_relative '../spec_helper'
require 'sequel'

# @type [Sequel::Database]
$DB = Sequel.connect('postgres://postgres@postgres:5432/umdio')
$DB.extension :pg_array, :pg_json, :pagination
Sequel.extension :pg_json_ops

describe 'Bus Endpoint v1', :endpoint, :buses do
  include BusMatchers

  url = '/v1/bus'
  bad_route_message = "umd.io doesn't know the bus route in your url. Full list at https://api.umd.io/v1/bus/routes"
  bad_stop_message = "umd.io doesn't know the stop in your url. Full list at https://api.umd.io/v1/bus/routes"
  # NOTE(don): cannot be done in before all block, needed in describe call and
  # before_all is run after describe call but before it call
  route = $DB[:routes].select(:route_id, :stops).first

  raise 'Route query returned no data. Make sure the query is conformant to the routes schema.' if route.nil? || route.empty?

  # @type [Integer]
  route_id = route[:route_id]
  # @type [String]
  first_stop = route[:stops][0]

  raise "Bad route shape, got id '#{route_id}' and stop '#{first_stop}'" unless !route_id&.empty? && !first_stop&.empty?

  # Bus matchers and examples

  shared_examples_for 'successful bus route list payload' do |url|
    before { get url }

    it 'has a good response' do
      expect(last_response.status).to be == 200
      expect(last_response.body.length).to be > 1
    end

    it 'sets the content-type header to application/json' do
      expect(last_response.headers['Content-Type']).to match_regex(%r{^application/json})
    end

    it 'has a payload containing a list of bus routes' do
      payload = JSON.parse(last_response.body)
      expect(payload).to be_a_kind_of Array
      expect(payload).to all be_a_bus_route
    end
  end

  describe 'get /bus' do
    it_has_behavior 'good status', url
  end

  describe 'get /routes' do
    it_has_behavior 'successful bus route list payload', url + '/routes'
  end

  describe 'get /routes/:route_id' do
    it_has_behavior 'good status', url + "/routes/#{route_id}"
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE', bad_route_message
  end

  describe 'get /routes/:route_id/schedules' do
    it_has_behavior 'good status', url + "/routes/#{route_id}/schedules"
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE/schedules', bad_route_message
  end

  describe 'get /routes/:route_id/arrivals/:stop_id' do
    context 'when both the route and stop are valid' do
      let(:res) { JSON.parse(last_response.body) }

      include_examples 'good status', url + "/routes/#{route_id}/arrivals/#{first_stop}"

      it 'returns a hash' do
        expect(res).to be_a Hash
      end

      it 'matches the correct shape' do
        expect(res).to include(
          'copyright' => (a_kind_of String),
          'predictions' => include(
            'routeTag' => route_id,
            'stopTag' => first_stop,
            'routeTitle' => (a_kind_of String),
            'agencyTitle' => (a_kind_of String),
            'dirTitleBecauseNoPredictions' => (a_kind_of String),
            'message' => (a_kind_of Array).and(all(include(
                                                     'text' => (a_kind_of String),
                                                     'priority' => (a_kind_of String)
                                                   )))
          )
        )
      end
    end

    context 'when either the route and/or stop are malformed or invalid' do
      it_has_behavior 'bad status', url + "/routes/#{route_id}/#{first_stop}"
      it_has_behavior 'bad status', url + "/routes/#{route_id}/arrivals"
      it_has_behavior 'bad status', url + "/routes/#{route_id}/arrivals/NOTASTOP"
      it_has_behavior 'bad status', url + '/routes/NOTAROUTE/arrivals/NOTASTOP'
    end
  end

  describe 'get /routes/:route_id/locations' do
    it_has_behavior 'good status', url + "/routes/#{route_id}/locations"
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE/locations'
  end

  describe 'get /locations' do
    let(:res) { JSON.parse(last_response.body) }

    include_examples 'good status', url + '/locations'

    it 'returns a Hash' do
      expect(res).to be_a Hash
    end

    it 'matches the expected shape' do
      expect(res).to include(
        'lastTime' => (a_kind_of Hash).and(include 'time' => match(/^\d+$/)),
        'copyright' => (a_kind_of String)
      )
    end
  end

  describe 'get /stops' do
    let(:res) { JSON.parse(last_response.body) }

    include_examples 'good status', url + '/stops'

    it 'returns a non-empty list' do
      expect(res).to be_an Array
      expect(res).not_to be_empty
    end

    it 'stop data matches the expected shape' do
      expect(res).to all include(
        'stop_id' => (a_kind_of String),
        'title' => (a_kind_of String)
      )
    end
  end

  describe 'get /stops/:stop_id' do
    context 'when a stop for stop_id exists' do
      let(:res) { JSON.parse(last_response.body) }

      include_examples 'good status', url + '/stops/regdrgar_d'

      it 'returns a hash' do
        pending 'Stop object is wrapped in a list for some reason'
        expect(res).to be_a hash
      end

      it 'returns a stop object' do
        expect(res).to include(
          'stop_id' => 'regdrgar_d',
          'title' => 'Regents Drive Garage',
          'lat' => (a_kind_of Float),
          'long' => (a_kind_of Float)
        )
      end
    end

    context 'when stop_id is malformed or no stop for it exists' do
      it_has_behavior 'bad status', url + '/stops/NOTASTOP'
    end
  end
end
