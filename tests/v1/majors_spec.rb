require_relative '../spec_helper'

describe 'Major Endpoint v1', :endpoint, :majors do
  url = '/v1/majors'

  describe 'get /' do
    let(:res) { JSON.parse(last_response.body) }

    include_examples 'good status', url

    it 'returns properly formatted data' do
      expect(res).not_to be_nil
      expect(res).to include(
        'message' => (a_kind_of String),
        'version' => (a_kind_of String),
        'docs' => (a_kind_of String),
        'endpoints' => (all a_kind_of String)
      )
    end
  end

  describe 'get /list' do
    let(:res) { JSON.parse(last_response.body) }

    include_examples 'good status', url + '/list'

    it 'returns a non-empty array' do
      expect(res).to be_an Array
      expect(res).not_to be_empty
    end

    it 'returns a list of majors' do
      expect(res).to all include(
        'major_id' => (a_kind_of Integer),
        'name' => (a_kind_of String),
        'url' => (a_string_matching URI::DEFAULT_PARSER.make_regexp),
        'college' => (a_kind_of String)
      )
    end
  end
end
