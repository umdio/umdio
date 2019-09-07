# umdio api core application. brings in other dependencies as needed.
ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/param'
require 'sinatra/namespace'
require 'json'
# TODO: Deprecated
require 'mongo'

# TODO: Deprecated?
require 'pg'

require 'sequel'

include Mongo

class UMDIO < Sinatra::Base
  # Explicitly set this as the root file
  set :root, File.dirname(__FILE__)

  # TODO: Load config from memory
  $DB = Sequel.connect('postgres://postgres@postgres:5432/umdio')
  $DB.extension :pg_array, :pg_json

  configure do
    # TODO: Deprecated. Use sequel instead.
    # set up mongo database - code from ruby mongo driver tutorial
    host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
    puts "Connecting to mongo on #{host}:#{port}"

    # TODO: Deprecated. Use sequel instead.
    db = PG.connect(
      dbname: 'umdio',
      host: 'postgres',
      port: '5432',
      user: 'postgres'
    )
    puts "Connecting to postgres on 5432"

    # TODO: Replace this with Sequel
    puts "Creating views"
    sql = File.open(File.join(File.dirname(__FILE__), '/startup.sql'), 'rb') { |file| file.read }
    db.exec(sql)

    # TODO: Elimiate these top two, and only go through Sequel
    set :buses_db, MongoClient.new(host,port, pool_size: 20, pool_timeout: 5).db('umdbus')
    set :postgres, db
    set :DB, DB
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
  Dir["./app/models/*.rb"].each { |file| require file }
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
