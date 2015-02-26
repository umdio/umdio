# tests/root_spec.rb
# tests for the root of the api

require_relative '../tests/spec_helper'

describe 'UMDIO API Version 0' do  # Probably should be moved higher up the test ladder. For now!
  url = '/'
  root_message = '{"message":"This is the umd.io JSON API.","status":"kinda working","docs":"http://umd.io/docs/","current_version":"v0","versions":[{"id":"v0","url":"http://api.umd.io/v0"}]}'
  version_message = '{"id":"v0","version":"0.0.1","name":"Some naming convention here","endpoints":[{"name":"Courses","url":"http://api.umd.io/v0/courses","docs":"http://umd.io/docs/courses"}]}'
  
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
      expect(last_response.body).to be == root_message
    end
  end

  describe 'v0' do
    it_has_behavior'good status', (url + 'v0')
    before {get url + 'v0'}
    it 'returns v0 message' do
      expect(last_response.body).to be == version_message
    end
  end

end