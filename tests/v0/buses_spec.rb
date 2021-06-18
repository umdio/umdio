require_relative '../spec_helper'
require 'sequel'

# @type [Sequel::Database]
$DB = Sequel.connect('postgres://postgres@postgres:5432/umdio')
$DB.extension :pg_array, :pg_json, :pagination
Sequel.extension :pg_json_ops

# Matches a float encoded as a string
FLOAT_REGEX = /^[+-]?(\d*[.])?\d+$/.freeze

describe 'Bus Endpoint v0' do
  url = '/v0/bus'
  bad_route_message = "umd.io doesn't know the bus route in your url. Full list at https://api.umd.io/v0/bus/routes"
  bad_stop_message = "umd.io doesn't know the stop in your url. Full list at https://api.umd.io/v0/bus/routes"
  route = $DB[:routes].select(:route_id, :stops).first

  raise 'Route query returned no data. Make sure the query is conformant to the routes schema.' if route.nil? || route.empty?

  # @type [Integer]
  route_id = route[:route_id]
  # @type [String]
  first_stop = route[:stops][0]

  raise "Bad route shape, got id '#{route_id}' and stop '#{first_stop}'" unless !route_id&.empty? && !first_stop&.empty?

  describe 'get list of routes' do
    it_has_behavior 'good status', url + '/routes'
  end

  describe 'get individual route data' do
    it_has_behavior 'good status', url + "/routes/#{route_id}"
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE', bad_route_message
  end

  describe 'get route schedules' do
    it_has_behavior 'good status', url + "/routes/#{route_id}/schedules"
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE/schedules', bad_route_message
  end

  describe 'get route predicted arrivals' do
    it_has_behavior 'good status', url + "/routes/#{route_id}/arrivals/#{first_stop}"
    it_has_behavior 'bad status', url + "/routes/NOTAROUTE/arrivals/#{first_stop}", bad_route_message
    it_has_behavior 'bad status', url + "/routes/#{route_id}/arrivals/NOTASTOP", bad_route_message
  end

  describe 'get locations of buses' do
    it_has_behavior 'good status', url + "/routes/#{route_id}/locations"
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE/locations', bad_route_message
  end

  describe 'get list of bus stops' do
    let(:res) { JSON.parse(last_response.body) }

    include_examples 'good status', url + '/stops'

    it 'returns a non-empty list' do
      expect(res).to be_an Array
      expect(res).to_not be_empty
    end

    it 'stop data matches the expected shape' do
      expect(res).to all include(
        'stop_id' => (a_kind_of String),
        'title' => (a_kind_of String)
      )
    end
  end

  describe 'get an individual bus stop' do
    context 'when the bus stop exists' do
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
          'lat' => (a_kind_of String).and(match FLOAT_REGEX),
          'lon' => (a_kind_of String).and(match FLOAT_REGEX)
        )
      end
    end

    context 'when the bus stop does not exist or the id is malformed' do
      it_has_behavior 'bad status', url + '/stops/NOTASTOP'
    end
  end
end
