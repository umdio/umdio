require_relative '../spec_helper'

describe 'Major Endpoint v1' do
  url = "v1/majors"

  describe 'get /majors' do
    it_has_behavior 'good status', url
    before {get url}
    it 'returns properly formatted data' do
      res = JSON::parse(last_response.body)
      expect(res).should_not be_nil
    end
  end

  describe 'get /majors' do
    it_has_behavior 'good status', url + '/list'

    before {get url + '/list'}
    it 'returns properly formatted data' do
      res = JSON::parse(last_response.body)
      expect(res).not_to be_empty

      res.each {|major|
        expect(major[:major_id]).should_not be_nil
        expect(major[:name]).should_not be_nil
        expect(major[:college]).should_not be_nil
        expect(major[:url]).should_not be_nil
      }
    end
  end
end