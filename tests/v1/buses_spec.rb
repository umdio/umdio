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

    let(:payload) { JSON.parse(last_response.body) }

    it 'has a good response' do
      expect(last_response.status).to be == 200
      expect(last_response.body.length).to be > 1
    end

    it 'sets the content-type header to application/json' do
      expect(last_response.headers['Content-Type']).to match_regex(%r{^application/json})
    end

    it 'has a payload containing a list of bus routes' do
      expect(payload).to be_a_kind_of Array
      expect(payload).to all be_a_bus_route
    end
  end

  describe 'get /bus' do
    it_has_behavior 'good status', url
  end

  describe 'get /routes' do
    include_examples 'successful bus route list payload', url + '/routes'

    it 'bus routes list is not empty' do
      expect(payload).not_to be_empty
    end
  end

  describe 'get /routes/:route_id' do
    context 'when the bus route id is invalid' do
      it_has_behavior 'bad status', url + '/routes/NOTAROUTE', bad_route_message
    end

    context 'when the bus route id is valid' do
      let(:payload) { JSON.parse(last_response.body) }

      include_examples 'good status', url + "/routes/#{route_id}"
      # NOTE: OpenAPI spec says this returns a hash, where the list is located
      # in the 'data' property. This isn't what's happening
      it 'the response payload is a non-empty list of hashes' do
        expect(payload).to be_a_kind_of(Array).and all a_kind_of(Hash)
        expect(payload.length).to be 1
      end

      context 'with the properties contained in the response payload' do
        # For some reason, this breaks
        let(:bus_route) { payload[0] }

        it 'includes a route_id which is the one specified in the request' do
          expect(bus_route['route_id']).to eq(route_id)
        end

        it 'the route hash has the correct shape' do
          expect(bus_route).to include(
            'route_id' => (a_kind_of String),
            'title' => (a_kind_of String),
            'lat_min' => (a_kind_of Numeric),
            'lat_max' => (a_kind_of Numeric),
            'long_min' => (a_kind_of Numeric),
            'long_max' => (a_kind_of Numeric),
            'stops' => (a_kind_of Array),
            'paths' => (a_kind_of Array),
            'directions' => (a_kind_of Array)
          )
        end

        it 'includes a list of stops' do
          actual = bus_route['stops']
          expect(actual).to be_a_kind_of(Array).and populated.and all be_a_kind_of(String)
          # expect(actual).not_to be_empty
        end

        it 'includes a list of paths' do
          actual = bus_route['paths']
          # Paths is a list of lists
          expect(actual).to be_a_kind_of(Array).and populated.and all be_a_kind_of(Array)
          expect(actual).not_to be_empty
          expect(actual).to all all include(
            'lat' => (a_kind_of Numeric),
            'long' => (a_kind_of Numeric)
          )
        end

        context 'with a list of directions' do
          let(:actual) { bus_route['directions'] }

          it 'is a populated array of hashes' do
            expect(actual).to be_an(Array).and populated.and all a_kind_of(Hash)
          end

          it 'each direction hash has the correct shape' do
            expect(actual).to all include(
              'direction_id' => (a_kind_of String),
              'title' => (a_kind_of String),
              'stops' => (a_kind_of(Array).and all be_a_kind_of(String))
            )
          end
        end
      end
    end
  end

  describe 'get /routes/:route_id/schedules' do
    context 'when the route_id is malformed or an unknown route code' do
      it_has_behavior 'bad status', url + '/routes/NOTAROUTE/schedules', bad_route_message
    end

    context 'when the route_id is well-formed and known' do
      let(:payload) { JSON.parse(last_response.body) }

      include_examples 'good status', url + "/routes/#{route_id}/schedules"

      it 'returns a non-empty list of Hashes' do
        expect(payload).to be_a_kind_of Array
        expect(payload).not_to be_empty
        expect(payload).to all be_a_kind_of(Hash)
      end

      context 'each returned schedule' do
        it 'has the correct shape' do
        expect(payload).to all include(
          'days' => (a_kind_of String),
          'direction' => (a_kind_of String),
          'route' => (a_kind_of String),
          'stops' => (a_kind_of Array),
          'trips' => (a_kind_of Array)
        )
        end

        it 'has a well-formed list of stops' do
          payload.each do |schedule|
            expect(schedule['stops']).to all include(
              'stop_id' => (a_kind_of String),
              'name' => (a_kind_of String)
            )
          end
        end

        it 'has a well-formed list of trips' do
          payload.each do |schedule|
            expect(schedule['trips']).to all be_a_kind_of(Array).and populated
            expect(schedule['trips']).to all all(
              be_a_kind_of(Hash).and include(
                'stop_id' => (a_kind_of String),
                'arrival_time' => (a_kind_of String),
                'arrival_time_secs' => (a_kind_of Integer)
              )
            )
          end
        end
      end
    end
  end

  describe 'get /routes/:route_id/arrivals/:stop_id' do
    context 'when both the route and stop are valid' do
      it_has_behavior 'good status', url + "/routes/#{route_id}/arrivals/#{first_stop}"
      it_has_behavior 'bad status', url + '/routes/NOTAROUTE/arrivals/YOOO', bad_route_message
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
    it_has_behavior 'good status', url + '/locations'
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
