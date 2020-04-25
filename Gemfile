source 'https://rubygems.org'

gem 'sinatra', "~> 2.0.8.1"
gem 'sinatra-contrib'
gem 'sinatra-cross_origin', '~> 0.4.0'
gem 'sinatra-param', '~> 1.6'
gem 'rake'
gem 'dotenv'
gem "pg", "~> 1.2.3"
gem "sequel", "~> 5.31"
gem "puma", "~> 4.3"

group :development do
  gem 'rspec'
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
