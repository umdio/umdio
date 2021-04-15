require 'rspec/core/rake_task'
require_relative 'app/helpers/courses_helpers.rb'
include Sinatra::UMDIO::Helpers

# Functions

def get_semesters(args)
  semesters = args.map do |e|
    if e.length == 6
      e
    else
      [e + '01', e + '05', e + '08', e + '12']
    end
  end
  semesters.flatten
end

# Scrapes the current semester from Testudo
def scrape_courses sems
  sh "ruby app/scrapers/courses_scraper.rb #{sems}"
  sh "ruby app/scrapers/sections_scraper.rb #{sems}"
end

# Imports old semesters from flat files
def import_courses sems
  sems = get_semesters(sems)
  sems.each {|s| sh "ruby app/scrapers/courses_importer.rb #{s}"}
end

def scrape_bus
  sh 'ruby app/scrapers/bus_routes_scraper.rb rebuild'
  sh 'ruby app/scrapers/bus_schedules_scraper.rb rebuild'
end

def scrape_majors
  sh 'ruby app/scrapers/majors_scraper.rb'
end

def scrape_map
  sh 'ruby app/scrapers/map_scraper.rb'
end

###### Scraping
desc "Scrape to fill databases"
task :scrape => ['scrape:courses', 'scrape:bus', 'scrape:buildings', 'scrape:majors']

desc "Scrapes enough to run the tests"
task :test_scrape do
  import_courses(['201808'])
  scrape_bus()
  scrape_majors()
  scrape_map()
end

namespace :scrape do
  desc "Run bus route scrapers"
  task :bus do
    scrape_bus()
  end

  desc "Run course scrapers"
  task :courses do
    # Testudo updated in September for Spring, Fed for fall
    # if fall is updated, we want to get the next year's courses
    year = Time.now.month <= 9 ? Time.now.year : Time.now.year + 1
    years = ((year - 3)..year).to_a.join ' '
    scrape_courses(years)
  end

  desc "Run course seat updater"
  task :seats do
    semesters = current_and_next_semesters
    sh "ruby app/scrapers/sections_scraper.rb #{semesters.join(' ')}"
  end

  desc "Run building scraper"
  task :buildings do
    scrape_map()
  end

  desc "Majors scraper"
  task :majors do
    scrape_majors()
  end

  desc "Scrapes only the current semester courses/sections"
  task :current do
    scrape_courses(current_semester)
  end

  desc "Import from file"
  task :import_courses do
    years = ['201708', '201712', '201801', '201805', '201808', '201812', '201901', '201901', '201905', '201908', '201912']
    import_courses(years)
  end
end

###### Server

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

desc "Type check and lint codebase"
task :validate do
  system 'bundle exec solargraph scan', exception: true
  system 'bundle exec solargraph typecheck', exception: true
  # TODO: run rubocop
end

task :default => ['up']
