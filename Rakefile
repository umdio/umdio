require 'rspec/core/rake_task'
require_relative 'app/helpers/courses_helpers.rb'
include Sinatra::UMDIO::Helpers

###### Scraping
desc "Scrape to fill databases (takes ~20 minutes)"
task :scrape => ['scrape:courses', 'scrape:bus', 'scrape:buildings', 'scrape:majors']

desc "Scrapes enough to run the tests"
task :test_scrape do
  # Get the current semester
  year = Time.now.month <= 10 ? Time.now.year : Time.now.year + 1
  semesters = [] << current_semester
  sh "ruby app/scrapers/courses_scraper.rb #{current_semester}"
  sh "ruby app/scrapers/sections_scraper.rb #{current_semester}"
  sh 'ruby app/scrapers/bus_routes_scraper.rb'
  sh 'ruby app/scrapers/bus_schedules_scraper_small.rb'
  sh 'ruby app/scrapers/map_scraper.rb'
  sh 'ruby app/scrapers/majors_scraper.rb'
end

namespace :scrape do
  desc "Run bus route scrapers"
  task :bus do
    sh 'ruby app/scrapers/bus_routes_scraper.rb rebuild'
    sh 'ruby app/scrapers/bus_schedules_scraper_small.rb rebuild'
  end

  desc "Run course scrapers"
  task :courses do
    # Testudo updated in September for Spring, Fed for fall
    # if fall is updated, we want to get the next year's courses
    year = Time.now.month <= 9 ? Time.now.year : Time.now.year + 1
    years = ((year - 3)..year).to_a.join ' '
    semesters = current_and_next_semesters
    sh "ruby app/scrapers/courses_scraper.rb #{years}"
    sh "ruby app/scrapers/sections_scraper.rb #{years}"
  end

  desc "Run course seat updater"
  task :seats do
    year = Time.now.month <= 9 ? Time.now.year : Time.now.year + 1
    years = ((year - 3)..year).to_a.join ' '
    semesters = current_and_next_semesters
    sh "ruby app/scrapers/sections_scraper.rb #{semesters.join(' ')}"
  end

  desc "Run building scraper"
  task :buildings do
    sh 'ruby app/scrapers/map_scraper.rb'
  end

  desc "Majors scraper"
  task :majors do
    sh 'ruby app/scrapers/majors_scraper.rb'
  end

  desc "Scrapes only the current semester courses/sections"
  task :current do
    sh "ruby app/scrapers/courses_scraper.rb #{current_semester}"
    sh "ruby app/scrapers/sections_scraper.rb #{current_semester}"
  end
end

###### Server

task :setup => ['db:clean','db:up','scrape']

desc "Start the web server for dev"
task :up do
  system "shotgun -p 3000 -o 0.0.0.0"
end
task :server => :up

desc "Start the web server for prod"
task :prod do
  system "puma -p 3000"
end

desc "Sinatra console"
task :console do
  system "bundle exec irb -r ./config.ru"
end
task :c => :console

###### Testing

desc "Run tests in /tests that look like *_spec.rb"
RSpec::Core::RakeTask.new :test do |task|
  task.pattern = Dir['tests/**/*_spec.rb']
  task.rspec_opts = "--format documentation" #default to verbose testing, comment for silence
end
task :spec => :test

desc "Run tests in /tests/v1 that look like *_spec.rb"
RSpec::Core::RakeTask.new :testv1 do |task|
  task.pattern = Dir['tests/v1/*_spec.rb']
  task.rspec_opts = "--format documentation" #default to verbose testing, comment for silence
end

task :default => ['test']
