require_relative '../tests/spec_helper'

describe 'Bus Endpoint' do
  url = "v0/bus"
  bad_route_message = "umd.io doesn't know the bus route in your url. Full list at http://api.umd.io/v0/bus/routes"
  bad_stop_message = "umd.io doesn't know the stop in your url. Full list at http://api.umd.io/v0/bus/routes"

  shared_examples_for 'good status' do |url|
    before {get url}
    it 'has a good response' do
      expect(last_response.status).to be == 200
      expect(last_response.body.length).to be > 1
    end
  end

  shared_examples_for 'error' do |url, message|
    before {get url}
    it 'yields 4xx error code' do
      expect(last_response.status).to be > 399 and be < 500
    end
    it 'provides a useful error message' do
      expect(last_response.body).to include message
    end
  end

  describe 'get list of routes' do
    it_has_behavior 'good status', url + '/routes'
  end

  describe 'get individual route data' do
    it_has_behavior 'good status', url + '/routes/118'
    it_has_behavior 'error', url + '/routes/NOTAROUTE', bad_route_message
  end

  describe 'get route schedules' do
    it_has_behavior 'good status', url + '/routes/118/schedules'
    it_has_behavior 'error', url + '/routes/NOTAROUTE/schedules', bad_route_message
  end

  describe 'get route predicted arrivals' do
    it_has_behavior 'good status', url + '/routes/115/arrivals/stamsu_d' 
    it_has_behavior 'error', url + '/routes/NOTAROUTE/arrivals/stamsu_d', bad_route_message
  end

  describe 'get locations of buses' do
    it_has_behavior 'good status', url + '/routes/115/locations'
    it_has_behavior 'error', url + '/routes/NOTAROUTE/locations', bad_route_message
  end

end