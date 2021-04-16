require_relative '../spec_helper'

describe 'Major Endpoint v0' do
  url = "v0/majors"

  describe 'get /' do
    it_has_behavior 'good status', url

    before {get url}
    it 'returns properly formatted data' do
      res = JSON::parse(last_response.body)
      expect(res).not_to be_empty

      res.each {|major|
        expect(major['major_id']).not_to be_nil
        expect(major['name']).not_to be_nil
        expect(major['college']).not_to be_nil
        expect(major['url']).not_to be_nil
      }
    end
  end
end
