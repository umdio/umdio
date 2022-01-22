require_relative '../spec_helper'

describe 'Map Endpoints v1', :endpoint, :map do
  let(:res) { JSON.parse(last_response.body) }

  url = '/v1/map'

  describe 'get /map' do
    it_has_behavior 'good status', url
  end

  describe 'get /map/buildings' do
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
    context 'when :building_id is valid' do
      include_examples 'good status', url + '/buildings/251'

      it 'returns an object with data and count properties' do
        expect(res).to be_a Hash
        expect(res).to include(
          'data' => (a_kind_of Array),
          'count' => (a_kind_of Integer)
        )
      end

      it 'count property is the same as the data array' do
        expect(res['data'].length).to eq res['count']
      end

      it 'data property is a building object' do
        expect(res['data']).to all include(
          'name' => (a_kind_of String),
          'code' => (a_kind_of String),
          'id' => (a_kind_of String),
          'lat' => (a_kind_of Float),
          'long' => (a_kind_of Float)
        )
      end
    end

    it_has_behavior '404', url + '/buildings/aaa'
    it_has_behavior '400', url + '/buildings/a'
    it_has_behavior '400', url + '/buildings/aaaaaaa'
  end
end
