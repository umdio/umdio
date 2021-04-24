require_relative '../spec_helper'

describe 'Major Endpoint v1', :endpoint, :majors do
  url = 'v1/majors'

  describe 'get /' do
    it_has_behavior 'good status', url
    before { get url }
    it 'returns properly formatted data' do
      res = JSON.parse(last_response.body)
      expect(res).not_to be_nil
    end
  end

  describe 'get /list' do
    it_has_behavior 'good status', url + '/list'

    before { get url + '/list' }
    it 'returns properly formatted data' do
      res = JSON.parse(last_response.body)
      expect(res).not_to be_empty

      res.each do |major|
        expect(major['major_id']).not_to be_nil
        expect(major['name']).not_to be_nil
        expect(major['college']).not_to be_nil
        expect(major['url']).not_to be_nil
      end
    end
  end
end
