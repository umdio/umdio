require_relative '../spec_helper'


describe 'Bus Endpoint v1', :endpoint, :buses do
  include BusMatchers

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

  url = 'v1/bus'
  bad_route_message = "umd.io doesn't know the bus route in your url. Full list at https://api.umd.io/v1/bus/routes"
  bad_stop_message = "umd.io doesn't know the stop in your url. Full list at https://api.umd.io/v1/bus/routes"

  describe 'get /routes' do
    it_has_behavior 'successful bus route list payload', url + '/routes'
  end

  describe 'get /routes/:route_id' do
    it_has_behavior 'good status', url + '/routes/118'
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE', bad_route_message
  end

  describe 'get /routes/:route_id/schedules' do
    it_has_behavior 'good status', url + '/routes/118/schedules'
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE/schedules', bad_route_message
  end

  describe 'get /routes/:route_id/arrivals/:stop_id' do
    # TODO: Change to good
    it_has_behavior 'bad status', url + '/routes/118/stamsu_d'
    it_has_behavior 'bad status', url + '/routes/118/arrivals'
    it_has_behavior 'bad status', url + '/routes/118/arrivals/NOTASTOP'
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE/arrivals/NOTASTOP'
  end

  describe 'get /routes/:route_id/locations' do
    it_has_behavior 'error status', url + '/routes/118/locations'
    it_has_behavior 'bad status', url + '/routes/NOTAROUTE/locations'
  end

  describe 'get /locations' do
    it_has_behavior 'error status', url + '/locations'
  end

  describe 'get /stops' do
    it_has_behavior 'good status', url + '/stops'
  end

  describe 'get /stops/:stop_id' do
    it_has_behavior 'good status', url + '/stops/stamsu_d'
    it_has_behavior 'bad status', url + '/stops/NOTASTOP'
  end
end
