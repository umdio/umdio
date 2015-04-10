require 'simplecov'
SimpleCov.start
require 'json'

#spec_helper.rb
ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'server')

RSpec.configure do |config|
  
  include Rack::Test::Methods
  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  
  def app
    UMDIO
  end
  
end