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
    before {get url}
    it 'has a good response' do
      expect(last_response.status).to be == 200
      expect(last_response.body.length).to be > 1
    end
  end

  shared_examples_for 'bad status' do |url|
    before {head url}
    it 'responds with 4xx' do
      expect(last_response.status).to be > 399
      expect(last_response.status).to be < 500
    end
  end

  def app
    UMDIO
  end

  def get_json url
    response = get(url)
    JSON.parse(response.body)
  end

end
