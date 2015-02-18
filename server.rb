#umdio api core application. brings in other dependencies as needed.
ENV['RACK_ENV'] ||= 'development'
 
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/json'
require 'mongo'

#require 'json/ext' # required for .to_json

include Mongo

class UMDIO < Sinatra::Base
  #Explicitly set this as the root file
  set :root, File.dirname(__FILE__)

  configure do
    #set up mongo database - code from ruby mongo driver tutorial
    host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
    puts "Connecting to mongo on #{host}:#{port}"
    #we might need other databases for other endpoints, but for now this is fine, with multiple collections
    set :db, MongoClient.new(host, port).db('umdclass') 
  end

  configure :development do
    #This is just to get the ability to make changes here and see them live without reloading the server
    #Still not quite working for reloading other files, not sure what the issue is there...
    register Sinatra::Reloader
  end
  
  #load in the other files
  require './courses/courses.rb'
  require './courses/courses_helpers.rb'
  require './root.rb'


  #register the helpers
  helpers Sinatra::UMDIO::Helpers

  #register the routes
  register Sinatra::UMDIO::Routing::Courses
  register Sinatra::UMDIO::Routing::Root

end