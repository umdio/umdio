# Tests for root of api

require_relative '../tests/spec_helper'

describe 'UMDIO API Version 0' do
  url = '/'

  describe 'Root' do
    it_has_behavior 'good status', url
    before {get url}
    it 'Returns root message' do
      res = JSON::parse(last_response.body)
      expect(res["message"]).to be
    end
  end

  describe 'v0' do
    it_has_behavior 'good status', (url + 'v0')
  end

  describe 'Bad route' do
    it_has_behavior 'bad status', (url + 'zzzz')
  end
end