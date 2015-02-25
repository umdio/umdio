source 'https://rubygems.org'

gem 'sinatra'
gem 'mongo'
gem 'bson_ext', '~> 1.12.0'
gem 'sinatra-contrib'
gem 'rake'
gem 'dotenv'
gem 'rack-rewrite', '~> 1.5.0'
gem 'jekyll'

group :development do
  gem 'rspec'
  gem 'sinatra-reloader', :require => 'sinatra/reloader'
  gem 'pry'
  gem 'shotgun'
end

group :test do
  gem 'rack-test', :require => 'rack/test'
  gem 'simplecov', :require => false
end

# the gems needed for the courses scraper, and likely for other scrapers
group :scrape do
  gem 'mechanize'
  gem 'nokogiri'
end
