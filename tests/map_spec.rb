require_relative '../tests/spec_helper'

describe 'Map Endpoint' do
  url = "v0/map"

  describe 'get /map' do
    it_has_behavior 'good status', url
  end

  describe 'get /map/buildings' do
    it_has_behavior 'good status', url + '/buildings'
  end

  describe 'get /map/buildings/:building_id' do
    it_has_behavior 'good status', url + '/buildings/251'
    it_has_behavior 'bad status', url + '/buildings/aaa'
  end
end