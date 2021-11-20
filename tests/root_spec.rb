# Tests for root of api

require 'net/http'
require_relative 'spec_helper'

describe 'umdio API', :endpoint do
  url = '/'

  describe 'Root' do
    include_examples 'good status', url

    it 'Returns root message' do
      res = JSON.parse(last_response.body)
      expect(res['message']).to be
    end
  end

  describe 'v0' do
    it_has_behavior 'good status', (url + 'v0')
  end

  describe 'v1' do
    it_has_behavior 'good status', (url + 'v1')

    describe 'spec.yaml' do
      
      before { get (url + 'v1/spec.yaml') }

      it 'has a good response' do
        expect(last_response.status).to be == 200
        expect(last_response.body.length).to be > 1
      end


      it 'sets the "Content-Type" header to "application/yaml"' do
        expect(last_response.headers['Content-Type']).to match(%r{^application/yaml})
      end

      it 'is a valid OpenAPI spec' do
        expect(valid_openapi?(last_response.body)).to be_truthy
      end
    end
  end

  describe 'Bad route' do
    it_has_behavior 'bad status', (url + 'zzzz')
  end
end

# Checks if openapi.yaml is a valid OpenAPI spec. Throws if the spec is invalid,
# otherwise returns true.
#
# @param [String] openapi the OpenAPI spec contents
#
def valid_openapi?(openapi)
  validator_url = URI('https://validator.swagger.io/validator/debug')
  headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/yaml' }
  res = Net::HTTP.post(validator_url, openapi, headers)
  parsed = JSON.parse res.body

  if parsed['messages']
    messages = parsed['schemaValidationMessages'].map { |m| m['message'] }.join(', ')
    raise StandardError, "Invalid openapi spec: #{messages}"
  end

  true
end
