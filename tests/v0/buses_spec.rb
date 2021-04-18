# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Bus Endpoint' do
  url = 'v0/bus'
  bad_route_message = "umd.io doesn't know the bus route in your url. Full list at https://api.umd.io/v0/bus/routes"
  bad_stop_message = "umd.io doesn't know the stop in your url. Full list at https://api.umd.io/v0/bus/routes"

  describe 'get list of routes' do
    it_has_behavior 'good status', "#{url}/routes"
  end

  describe 'get individual route data' do
    it_has_behavior 'good status', "#{url}/routes/118"
    it_has_behavior 'bad status', "#{url}/routes/NOTAROUTE", bad_route_message
  end

  describe 'get route schedules' do
    it_has_behavior 'good status', "#{url}/routes/118/schedules"
    it_has_behavior 'bad status', "#{url}/routes/NOTAROUTE/schedules", bad_route_message
  end

  describe 'get route predicted arrivals' do
    it_has_behavior 'good status', "#{url}/routes/115/arrivals/stamsu_d"
    it_has_behavior 'bad status', "#{url}/routes/NOTAROUTE/arrivals/stamsu_d", bad_route_message
  end

  describe 'get locations of buses' do
    it_has_behavior 'good status', "#{url}/routes/115/locations"
    it_has_behavior 'bad status', "#{url}/routes/NOTAROUTE/locations", bad_route_message
  end
end
