require 'simplecov'
SimpleCov.start

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'json'

ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'server')
require_relative 'matchers/bus_matcher'
require_relative 'matchers/helper_matcher'

# parallel specs
if ENV['TEST_ENV_NUMBER']
  # Wait until all threads finish to collect coverage report
  SimpleCov.at_exit do
    result = SimpleCov.result
    result.format! if ParallelTests.number_of_running_processes <= 1
  end
end

RSpec.configure do |config|
  include Rack::Test::Methods
  include BusMatchers
  include HelperMatchers

  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.color = true

  # mute noise for parallel tests
  config.silence_filter_announcements = true if ENV['TEST_ENV_NUMBER']

  shared_examples_for 'good status' do |url|
    before { get url }
    it 'has a good response' do
      expect(last_response.status).to be == 200
      expect(last_response.body.length).to be > 1
    end

    it 'sets the "Content-Type" header to "application/json"' do
      expect(last_response.headers['Content-Type']).to match(%r{^application/json})
    end
  end

  shared_examples_for 'bad status' do |url|
    before { get url }
    it 'yields 4xx error code' do
      expect(last_response.status).to be > 399 and be < 500
    end

    it 'sets the "Content-Type" header to "application/json"' do
      expect(last_response.headers['Content-Type']).to match(%r{^application/json})
    end

    describe 'with a response payload' do
      let(:res) { JSON.parse(last_response.body) }

      it 'sets the error_code field to the same value as the HTTP status code' do
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
    before { get url }
    it 'responds with 400' do
      expect(last_response.status).to be == 400
    end

    it 'sets the "Content-Type" header to "application/json"' do
      expect(last_response.headers['Content-Type']).to match(%r{^application/json})
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
    before { get url }
    it 'responds with 404' do
      expect(last_response.status).to eq 404
    end

    it 'sets the "Content-Type" header to "application/json"' do
      expect(last_response.headers['Content-Type']).to match(%r{^application/json})
    end

    describe 'with a response payload' do
      let(:res) { JSON.parse(last_response.body) }

      it 'sets the error_code payload to 404' do
        expect(res['error_code']).to eq 404
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

  shared_examples_for 'a scraper' do
    let(:instance) { described_class.new }

    it 'implements ScraperCommon' do
      expect(described_class).to be < ScraperCommon
    end

    it 'defines a scrape method' do
      expect(instance).to respond_to :scrape
    end

    context '#run_scraper' do
      it 'is present' do
        expect(instance).to respond_to :run_scraper
      end

      it 'is not overwritten by scraper implementation' do
        expect(instance.method(:run_scraper).owner).to eq ScraperCommon
      end

      it 'forwards arguments to #scrape' do
        instance.stub(:scrape) { |arg| arg }
        instance.run_scraper('some args')
        expect(instance).to have_received(:scrape).with('some args')
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
