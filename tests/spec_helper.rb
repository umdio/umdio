#spec_helper.rb
ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'server')
 
RSpec.configure do |config|
  include Rack::Test::Methods
 
  def app
    UMDIO
  end
end