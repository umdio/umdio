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

  describe 'get /bus' do
    it_has_behavior 'good status', url
  end

  describe 'get /routes' do
    # it_has_behavior 'successful bus route list payload', url + '/routes'
    let(:res) { JSON.parse(last_response.body) }

    include_examples 'good status', url + '/routes'

    it 'returns a non-empty list' do
      expect(res).to be_an Array
      expect(res).not_to be_empty
    end

    it 'returns a list of bus routes' do
      expect(res).to all be_a_bus_route
    end
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
      let(:preds) { res['predictions'] }

      include_examples 'good status', url + "/routes/#{route_id}/arrivals/#{first_stop}"

      it 'returns a hash with a copyright string and predictions object' do
        expect(res).to be_a Hash
        expect(res['copyright']).to be_a String
        expect(preds).to be_a Hash
      end

      context "the response's predictions object" do
        let(:direction) { preds['direction'] }

        it 'specifies UMD as the agency' do
          expect(preds['agencyTitle']).to eq 'University of Maryland'
        end

        it 'specifies route/stop tag and route/stop title data' do
          expect(preds).to include(
            'routeTag' => route_id,
            'stopTag' => first_stop,
            'routeTitle' => (a_kind_of String),
            'stopTitle' => (a_kind_of String)
          )
        end

        it 'has an optionl message property that is either a message object or a list of message objects' do
          msg = preds['msg']
          msg_shape = { 'text' => (a_kind_of String), 'priority' => (a_kind_of String) }
          expect(msg).to be_nil.or include(msg_shape).or(be_a_kind_of(Array).and(all(include(msg_shape))))
        end

        it 'has an explanation if no predictions are available' do
          expect(preds['dirTitleBecauseNoPredictions']).to be_a String if direction.nil? || direction['prediction'].nil?
        end

        it 'if available, directions object has a tit string and prediction list' do
          if direction
            expect(direction).to be_a Hash
            expect(direction).to include 'title' => (a_kind_of String), 'prediction' => (a_kind_of Array)
          end
        end

        it 'if available, prediction list contains objects of the expected shape' do
          if direction
            expect(direction['prediction']).to be_an Array
            expect(direction['prediction']).to all include(
              'affectedByLayover' => a_string_encoded_boolean,
              'seconds' => a_string_encoded_positive_int,
              'tripTag' => a_string_encoded_positive_int,
              'minutes' => a_string_encoded_positive_int,
              'isDeparture' => a_string_encoded_boolean,
              'block' => a_string_encoded_positive_int,
              'dirTag' => (a_kind_of String),
              'epochTime' => a_string_encoded_positive_int,
              'vehicle' => a_string_encoded_positive_int
            )
          end
        end
        # !context "the response's predictions object"
      end
    end

    context 'when either the route and/or stop are malformed or invalid' do
      it_has_behavior 'bad status', url + "/routes/#{route_id}/#{first_stop}"
      it_has_behavior 'bad status', url + "/routes/#{route_id}/arrivals"
      it_has_behavior 'bad status', url + "/routes/#{route_id}/arrivals/NOTASTOP"
      it_has_behavior 'bad status', url + '/routes/NOTAROUTE/arrivals/NOTASTOP'
    end
    # !describe 'get /routes/:route_id/arrivals/:stop_id'
  end

  describe 'get /routes/:route_id/locations' do
    it_has_behavior 'good status', url + "/routes/#{route_id}/locations"
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE/locations'
  end

  describe 'get /locations' do
    let(:res) { JSON.parse(last_response.body) }

    include_examples 'good status', url + '/locations'

    specify { expect(res).to be_a Hash }
    # it 'returns a Hash' do
    #   expect(res).to be_a Hash
    # end

    it 'matches the expected shape' do
      expect(res).to include(
        'lastTime' => (a_kind_of Hash).and(include 'time' => a_string_encoded_positive_int),
        'copyright' => String
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
        expect(res).to be_a Hash
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
