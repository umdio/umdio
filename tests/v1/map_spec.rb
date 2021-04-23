require_relative '../spec_helper'

describe 'Map Endpoints v1', :endpoint, :map do
  url = 'v1/map'

  describe 'get /map' do
    it_has_behavior 'good status', url
  end

  describe 'get /map/buildings' do
    it_has_behavior 'good status', url + '/buildings'
  end

  describe 'get /map/buildings/:building_id' do
    it_has_behavior 'good status', url + '/buildings/251'

    it_has_behavior '404', url + '/buildings/aaa'
    it_has_behavior '400', url + '/buildings/a'
    it_has_behavior '400', url + '/buildings/aaaaaaa'
  end
end
