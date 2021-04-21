# frozen_string_literal: true

# umdio api core application. brings in other dependencies as needed.
ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'sinatra/base'
require 'sinatra/param'
require 'sinatra/namespace'
require 'sinatra/cross_origin'
require 'sinatra/json'
require 'sequel'

class UMDIO < Sinatra::Base
  # Explicitly set this as the root file
  set :root, File.dirname(__FILE__)

  # TODO: Load config from memory
  # @type [Sequel::Database]
  $DB = Sequel.connect('postgres://postgres@postgres:5432/umdio')
  $DB.extension :pg_array, :pg_json, :pagination
  Sequel.extension :pg_json_ops

  configure do
    enable :cross_origin
  end

  # before application/request starts
  before do
    content_type 'application/json'
    cache_control :public, max_age: 86_400
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
  end

  # load in app helpers & controllers
  Dir['./app/helpers/*.rb'].each { |file| require file }
  Dir['./app/controllers/*.rb'].each { |file| require file }
  Dir['./app/models/*.rb'].each { |file| require file }

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
