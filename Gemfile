source 'https://rubygems.org'

ruby '~> 2.7'

gem 'dotenv'
gem 'pg', '~> 1.2.3'
gem 'puma', '~> 4.3'
gem 'rake'
gem 'sequel', '~> 5.31'
gem 'sinatra', '~> 2.0.8.1'
gem 'sinatra-contrib'
gem 'sinatra-cross_origin', '~> 0.4.0'
gem 'sinatra-param', '~> 1.6'

group :development do
  gem 'better_errors'
  gem 'rspec'
  gem 'shotgun'
  gem 'solargraph'
  gem 'debase'
  gem 'ruby-debug-ide', require: false
  gem 'rubocop', '~> 1.12', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-sequel', require: false
end

group :test do
  gem 'rack-test', require: 'rack/test'
  gem 'simplecov', require: false
  gem 'codecov', :require => false, :group => :test
  gem 'json-schema'
end

# the gems needed for the courses scraper, and likely for other scrapers
group :scrape do
  gem 'nokogiri'
end
