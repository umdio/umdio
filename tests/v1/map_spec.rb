require_relative '../spec_helper'

describe 'Map Endpoints v1', :endpoint, :map do
  url = '/v1/map'

  describe 'get /map' do
    it_has_behavior 'good status', url
  end

  describe 'get /map/buildings' do
    let(:res) { JSON.parse(last_response.body) }

    include_examples 'good status', url + '/buildings'

    it 'returns a nonempty array' do
      expect(res).to be_an Array
      expect(res).not_to be_empty
    end

    it 'returns a list of buildings' do
      expect(res).to all include(
        'name' => (a_kind_of String),
        'code' => (a_kind_of String),
        'id' => (a_kind_of String),
        'lat' => (a_kind_of Float),
        'long' => (a_kind_of Float)
      )
    end
  end

  describe 'get /map/buildings/:building_id' do
    it_has_behavior 'good status', url + '/buildings/251'
    it_has_behavior '404', url + '/buildings/aaa'
    it_has_behavior '400', url + '/buildings/a'
    it_has_behavior '400', url + '/buildings/aaaaaaa'
  end
end
