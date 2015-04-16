require 'simplecov'
SimpleCov.start
require 'json'

ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'server')

RSpec.configure do |config|
  
  include Rack::Test::Methods
  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.color = true
  
  def app
    UMDIO
  end

  def get_json url
    response = get(url)
    JSON.parse(response.body)
  end

end
