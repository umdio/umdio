require 'rspec/core/rake_task'
#require File.expand_path('../config/application', __FILE__)
 
namespace :database do
  desc "Build Database"
  task :up => ['database:down'] do
    sh 'mongod --dbpath ./data/db --fork --logpath ./data/mongodb.log'
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
task :scrape => ['database:up'] do
  ruby 'courses/courses_scraper.rb'
end
task :setup => ['database:up','scrape']

desc "Start the web server"
task :up do
  #if ENV['RACK_ENV'] == :development
  `shotgun -p 3000`
end
task :server => :up

desc "Run tests in /tests that look like *_spec.rb"
RSpec::Core::RakeTask.new :test do |task|
  task.pattern = Dir['tests/**/*_spec.rb']
  task.rspec_opts = "--format documentation" #default to verbose testing, comment for silence
end
task :spec => :test

task :default => ['test']
