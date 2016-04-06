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
      puts "DANGER: killing mongod instances: #{mongo_pid}."
      mongo_pid.split("\n").each{|pid| `sudo kill 15 #{pid.to_i}`}
    else
      puts 'No mongod processes found -- free to go ahead'
    end
  end

  desc "clean database"
  task :clean do
    puts "DANGER: will remove everything in the database, including logs."
    `rm -r ./data/db`
    `rm -r ./data/mongo`
    `mkdir ./data/db`
    `mkdir ./data/mongo`
  end
end

desc "Scrape to fill databases" # takes about 15 minutes
task :scrape do
  sh 'ruby app/scrapers/courses_scraper.rb 2013 2014 2015 2016'
  sh 'ruby app/scrapers/sections_scraper.rb'
  sh 'ruby app/scrapers/section_course_linker.rb'
  # TODO: don't hardcode semester_id
  sh 'ruby app/scrapers/update_open_seats.rb 201608'
  sh 'ruby app/scrapers/bus_routes_scraper.rb'
  sh 'ruby app/scrapers/bus_schedules_scraper_small.rb'
  sh 'ruby app/scrapers/buildings.rb'
end

task :setup => ['db:clean','db:up','scrape']

desc "Start the web server"
task :up do
  #if ENV['RACK_ENV'] == :development
  system "shotgun -p 3000 -o 0.0.0.0"
end
task :server => :up

desc "Sinatra console"
task :console do
  system "bundle exec irb -r ./config.ru"
end
task :c => :console

desc "Run tests in /tests that look like *_spec.rb"
RSpec::Core::RakeTask.new :test do |task|
  task.pattern = Dir['tests/**/*_spec.rb']
  task.rspec_opts = "--format documentation" #default to verbose testing, comment for silence
end
task :spec => :test

task :default => ['test']
