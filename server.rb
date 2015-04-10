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
  set :server, 'webrick'

  configure do
    # set up mongo database - code from ruby mongo driver tutorial
    host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
    puts "Connecting to mongo on #{host}:#{port}"
    # we might need other databases for other endpoints, but for now this is fine, with multiple collections
    set :courses_db, MongoClient.new(host, port, pool_size: 20, pool_timeout: 5).db('umdclass') 
    set :buses_db, MongoClient.new(host,port, pool_size: 20, pool_timeout: 5).db('umdbus')
    set :map_db, MongoClient.new(host,port, pool_size: 20, pool_timeout: 5).db('umdmap')
  end

  configure :development do
  end

  # load in the other files
  require './app/controllers/courses_controller.rb'
  require './app/controllers/bus_controller.rb'
  require './app/controllers/map_controller.rb'
  require './app/helpers/courses_helpers.rb'
  require './app/helpers/bus_helpers.rb'
  require './app/helpers/map_helpers.rb'
  require './root.rb'

  # register the helpers
  helpers Sinatra::UMDIO::Helpers
  helpers Sinatra::Param

  # register the routes
  register Sinatra::UMDIO::Routing::Courses
  register Sinatra::UMDIO::Routing::Bus
  register Sinatra::UMDIO::Routing::Map
  register Sinatra::UMDIO::Routing::Root

end