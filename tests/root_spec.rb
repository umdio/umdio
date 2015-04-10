# tests/root_spec.rb
# tests for the root of the api

require_relative '../tests/spec_helper'

describe 'UMDIO API Version 0' do  # Probably should be moved higher up the test ladder. For now!
  url = '/'
  
  shared_examples_for 'good status' do |url|
    before {head url}
    it 'has a good response' do
      expect(last_response.status).to be == 200
    end
  end

  describe 'Root' do
    it_has_behavior 'good status', url
    before {get url}
    it 'Returns root message' do
      res = JSON::parse(last_response.body)
      expect(res["message"]).to be
    end
  end

  describe 'v0' do
    it_has_behavior'good status', (url + 'v0')
    before {get url + 'v0'}
    it 'returns v0 message' do
      # TODO
      # expect(last_response.body).to be == version_message
    end
  end

end