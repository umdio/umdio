source 'https://rubygems.org'

gem 'sinatra'
gem 'sinatra-cross_origin', '~> 0.4.0'
gem 'sinatra-contrib'
gem 'sinatra-param', '~> 1.3'
gem 'rake'
gem 'dotenv'
gem "pg", "~> 1.1"
gem "sequel", "~> 5.21"
gem "puma", "~> 4.0"

group :development do
  gem 'rspec'
  gem 'sinatra-reloader', :require => 'sinatra/reloader'
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