require 'simplecov'
SimpleCov.start
require 'json'

ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'server')

RSpec.configure do |config|
  include Rack::Test::Methods
  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.color = true

  shared_examples_for 'good status' do |url|
    before { get url }
    it 'has a good response' do
      expect(last_response.status).to be == 200
      expect(last_response.body.length).to be > 1
    end
  end

  shared_examples_for 'bad status' do |url|
    before { get url }
    it 'yields 4xx error code' do
      expect(last_response.status).to be > 399 and be < 500
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
  end

  shared_examples_for '404' do |url|
    before { head url }
    it 'responds with 404' do
      expect(last_response.status).to be == 404
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
