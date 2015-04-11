require 'rspec/core/rake_task'
#require File.expand_path('../config/application', __FILE__)
 
namespace :db do
  desc "Build Database"
  task :up => ['db:down'] do
    sh 'mongod --dbpath ./data/db --fork --logpath ./data/mongo/mongodb.log' #works on mac, but not ubuntu
  end

  desc "Shutdown mongo database server"
  task :down do
    mongo_pid = `pgrep mongod`
    if (!mongo_pid.empty?) then
      puts "DANGER: killing mongod instances: #{mongo_pid}"
      mongo_pid.split("\n").each{|pid| Process.kill(15,pid.to_i)}
    else
      puts 'No mongod processes found -- free to go ahead'
    end
  end
end

desc "Scrape testudo to fill the database"
task :scrape do
  ruby 'app/scrapers/courses_scraper.rb'
  ruby 'app/scrapers/bus_routes_scraper.rb'
  ruby 'app/scrapers/map_controller.rb'
end

task :setup => ['scrape']

desc "Start the web server"
task :up do
  #if ENV['RACK_ENV'] == :development
  system "shotgun -p 3000"
end
task :server => :up

task :rerun do
  system "rerun 'rackup config.ru -p 3000'"
end

desc "Run tests in /tests that look like *_spec.rb"
RSpec::Core::RakeTask.new :test do |task|
  task.pattern = Dir['tests/**/*_spec.rb']
  task.rspec_opts = "--format documentation" #default to verbose testing, comment for silence
end
task :spec => :test

task :default => ['test']
