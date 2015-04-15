source 'https://rubygems.org'

gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-param', '~> 1.3'
gem 'mongo'
gem 'bson_ext', '~> 1.12.0'
gem 'rake'
gem 'dotenv'
gem 'jekyll'
gem 'rouge'

group :development do
  gem 'rspec'
  gem 'sinatra-reloader', :require => 'sinatra/reloader'
  gem 'pry'
  gem 'shotgun'
  gem 'better_errors'
end

group :test do
  gem 'rack-test', :require => 'rack/test'
  gem 'simplecov', :require => false
end

# the gems needed for the courses scraper, and likely for other scrapers
group :scrape do
  gem 'nokogiri'
end
