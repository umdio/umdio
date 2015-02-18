#Gemfile
source 'https://rubygems.org'

group :default do  
  gem 'sinatra'
  gem 'mongo'
  gem 'bson_ext', '~> 1.12.0'
  gem 'sinatra-contrib'
  gem 'rake'
end

group :development do
  gem 'rspec'
  gem 'sinatra-reloader', :require => 'sinatra/reloader'
end

group :test do
  gem 'rack-test', :require => 'rack/test'
end

group :scrape do #the gems needed for the courses scraper, and likely for other scrapers
  gem 'mechanize'
  gem 'nokogiri'
end
