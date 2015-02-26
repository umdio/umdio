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

  configure do
    # set up mongo database - code from ruby mongo driver tutorial
    host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
    puts "Connecting to mongo on #{host}:#{port}"
    # we might need other databases for other endpoints, but for now this is fine, with multiple collections
    set :db, MongoClient.new(host, port).db('umdclass') 
  end

  configure :development do
  end

  # load in the other files
  require './app/controllers/courses_controller.rb'
  require './app/helpers/courses_helpers.rb'
  require './root.rb'

  # register the helpers
  helpers Sinatra::UMDIO::Helpers
  helpers Sinatra::Param

  # register the routes
  register Sinatra::UMDIO::Routing::Courses
  register Sinatra::UMDIO::Routing::Root

end