require_relative '../tests/spec_helper'

describe 'Map Endpoint' do
  url = "v0/map"

  shared_examples_for 'good status' do |url|
    before {get url}
    it 'has a good response' do
      expect(last_response.status).to be == 200
      expect(last_response.body.length).to be > 1
    end
  end

  describe 'get /map' do
    it_has_behavior 'good status', url
  end

  describe 'get /map/buildings' do
    it_has_behavior 'good status', url + '/buildings'
  end

  describe 'get /map/buildings/:building_id' do
    it_has_behavior 'good status', url + '/buildings/251'
  end

end