source 'https://rubygems.org'

group :services do
  gem 'rake'
  gem 'dotenv'
  gem "pg", "~> 1.1"
  gem "sequel", "~> 5.21"
  gem "puma", "~> 4.0"
end

group :runtime do
  gem 'sinatra'
  gem 'sinatra-contrib'
  gem 'sinatra-param', '~> 1.3'
end

group :scrape do
  gem 'nokogiri'
end

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