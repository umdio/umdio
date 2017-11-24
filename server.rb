# umdio api core application. brings in other dependencies as needed.
ENV['RACK_ENV'] ||= 'development'
 
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sinatra/param'
require 'sinatra/namespace'
require 'mongo'
require 'json'

include Mongo

class UMDIO < Sinatra::Base
  # Explicitly set this as the root file
  set :root, File.dirname(__FILE__)

  # fix strange scraper bug by explicitly setting the server
  # reference: http://stackoverflow.com/questions/17334734/how-do-i-get-sinatra-to-work-with-httpclient
  
  
  configure do
    # set up mongo database - code from ruby mongo driver tutorial
    host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
    puts "Connecting to mongo on #{host}:#{port}"
    # we might need other databases for other endpoints, but for now this is fine, with multiple collections
    set :courses_db, MongoClient.new(host, port, pool_size: 20, pool_timeout: 5).db('umdclass') 
    set :buses_db, MongoClient.new(host,port, pool_size: 20, pool_timeout: 5).db('umdbus')
    set :map_db, MongoClient.new(host,port, pool_size: 20, pool_timeout: 5).db('umdmap')
    #set :profs_db, MongoClient.new(host, port, pool_size: 20, pool_timeout: 5).db('umdprof')
    set :majors_db, MongoClient.new(host,port, pool_size: 20, pool_timeout: 5).db('umdmajors')
  end

  configure :development do
    # TODO: fix weird namespace conflict and install better_errors
    use BetterErrors::Middleware
    BetterErrors.application_root = __dir__
  end

  # before application/request starts
  before do
    content_type 'application/json'
    cache_control :public, max_age: 86400
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
  end

  # load in app helpers & controllers
  Dir["./app/helpers/*.rb"].each { |file| require file }
  Dir["./app/controllers/*.rb"].each { |file| require file }
  require './root.rb'

  # register the helpers
  helpers Sinatra::UMDIO::Helpers
  helpers Sinatra::Param

  # register the routes
  register Sinatra::UMDIO::Routing::Professors
  register Sinatra::UMDIO::Routing::Courses
  register Sinatra::UMDIO::Routing::Bus
  register Sinatra::UMDIO::Routing::Map
  register Sinatra::UMDIO::Routing::Majors
  register Sinatra::UMDIO::Routing::Root
end
