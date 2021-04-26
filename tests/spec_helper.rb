require 'simplecov'
SimpleCov.start
require 'json'

ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'server')


module BusMatchers
  extend RSpec::Matchers::DSL

  matcher :be_a_bus_route do
    match {|actual| actual.is_a?(Hash) and actual['route_id'].is_a?(String) and actual['title'].is_a?(String) }
  end
end

RSpec.configure do |config|
  include Rack::Test::Methods
  include BusMatchers

  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.color = true

  shared_examples_for 'good status' do |url|
    before { get url }
    it 'has a good response' do
      expect(last_response.status).to be == 200
      expect(last_response.body.length).to be > 1
    end

    it 'sets the "Content-Type" header to "application/json"' do
      expect(last_response.headers['Content-Type']).to match /^application\/json/
    end
  end

  shared_examples_for 'bad status' do |url|
    before { get url }
    it 'yields 4xx error code' do
      expect(last_response.status).to be > 399 and be < 500
    end

    it 'sets the "Content-Type" header to "application/json"' do
      expect(last_response.headers['Content-Type']).to match /^application\/json/
    end

    describe 'with a response payload' do
      let(:res) { JSON.parse(last_response.body) }

      it 'sets the error_code payload' do
        expect(res['error_code']).to eq last_response.status
      end

      it 'provides a message string' do
        expect(res['message']).to be_a_kind_of String
        expect(res['message'].length).to be > 0
      end

      it 'provides a link to the relevant documentation' do
        expect(res['docs']).to be_a_kind_of String
        expect(res['docs'].length).to be > 0
      end
    end
  end

  shared_examples_for 'error status' do |url, _message|
    before { get url }
    it 'yields 5xx error code' do
      expect(last_response.status).to be > 499 and be < 600
    end
  end

  shared_examples_for '400' do |url|
    before { head url }
    it 'responds with 400' do
      expect(last_response.status).to be == 400
    end

    it 'sets the "Content-Type" header to "application/json"' do
      expect(last_response.headers['Content-Type']).to match /^application\/json/
    end

    describe 'with a response payload' do
      let(:res) { JSON.parse(last_response.body) }

      it 'sets the error_code payload to 400' do
        expect(res['error_code']).to eq 400
      end

      it 'provides a message string' do
        expect(res['message']).to be_a_kind_of String
        expect(res['message'].length).to be > 0
      end

      it 'provides a link to the relevant documentation' do
        expect(res['docs']).to be_a_kind_of String
        expect(res['docs'].length).to be > 0
      end
    end
  end

  shared_examples_for '404' do |url|
    before { head url }
    it 'responds with 404' do
      expect(last_response.status).to be == 404
    end

    it 'sets the "Content-Type" header to "application/json"' do
      expect(last_response.headers['Content-Type']).to match /^application\/json/
    end

    describe 'with a response payload' do
      let(:res) { JSON.parse(last_response.body) }

      it 'sets the error_code payload to 404' do
        expect(res['error_code']).to eq 404
      end

      it 'provides a message string' do
        expect(res['message']).to be_a_kind_of String
        expect(res['message'].length).to.positive?
      end

      it 'provides a link to the relevant documentation' do
        expect(res['docs']).to be_a_kind_of String
        expect(res['docs'].length).to.positive?
      end
    end
  end

  def app
    UMDIO
  end

  def get_json(url)
    response = get(url)
    JSON.parse(response.body)
  end
end
