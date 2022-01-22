require_relative '../spec_helper'

describe 'Major Endpoint v0' do
  url = '/v0/majors'

  describe 'get /' do
    let(:res) { JSON.parse(last_response.body) }

    include_examples 'good status', url

    it 'returns a non-empty array' do
      expect(res).to be_an Array
      expect(res).not_to be_empty
    end

    it 'returns a list of majors' do
      expect(res).to all include(
        'major_id' => (a_kind_of String),
        'name' => (a_kind_of String),
        'url' => (a_string_matching URI::DEFAULT_PARSER.make_regexp),
        'college' => (a_kind_of String)
      )
    end
  end
end
