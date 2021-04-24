require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'net/http'
require 'json'
require_relative 'app/helpers/courses_helpers'


include Sinatra::UMDIO::Helpers

################################################################################
################################## FUNCTIONS ###################################
################################################################################

# Checks if openapi.yaml is a valid OpenAPI spec. Throws if the spec is invalid,
# otherwise returns true.
def validate_openapi
  File.open 'openapi.yaml' do |openapi|
    validator_url = URI("https://validator.swagger.io/validator/debug")
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/yaml' }
    res = Net::HTTP.post(validator_url, openapi.read, headers)
    parsed = JSON.parse res.body
    
    if parsed['messages'] 
      messages = parsed['schemaValidationMessages'].map{ |m| m['message'] }.join(', ')
      raise StandardError.new "Invalid openapi spec: #{messages}"
    end 
  end

  return true
end

# @param [Array<String>]
# @return [Array<String>]
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
def scrape_courses(sems)
  sh "ruby app/scrapers/courses_scraper.rb #{sems}"
  sh "ruby app/scrapers/sections_scraper.rb #{sems}"
end

# Imports old semesters from flat files
def import_courses(sems)
  sems = get_semesters(sems)
  sems.each { |s| sh "ruby app/scrapers/courses_importer.rb #{s}" }
end

def scrape_bus
  sh 'ruby app/scrapers/bus_routes_scraper.rb'
  sh 'ruby app/scrapers/bus_schedules_scraper.rb'
end

def scrape_majors
  sh 'ruby app/scrapers/majors_scraper.rb'
end

def scrape_map(args = '')
  sh "ruby app/scrapers/map_scraper.rb #{args}"
end

################################################################################
#################################### TASKS #####################################
################################################################################

################################### Imports ####################################
desc 'Import previously scraped data from the umdio-data repo'
task import: ['import:courses']

namespace :import do
  desc 'Import a specific semester'
  task :semester, [:sem] do |_task, args|
    import_courses([args[:sem]])
  end

  desc 'Import all past semesters'
  task :courses do
    years = %w[201708 201712 201801 201805 201808 201812 201901 201901 201905 201908 201912]
    import_courses(years)
  end

  desc 'Import map data'
  task :map do
    scrape_map './data/umdio-data/umd-building-gis.json'
  end
end

# TODO: Add export - see https://github.com/umdio/umdio-data/blob/master/courses/download-sem.rb

################################### Scraping ###################################
desc 'Scrape live data to fill databases'
task scrape: ['scrape:courses', 'scrape:bus', 'scrape:map', 'scrape:majors']

# TODO: Move this to an import task, once other datatypes are importable
desc 'Scrapes enough to run the tests'
task :test_scrape do
  import_courses(['201808'])
  scrape_bus
  scrape_majors
  scrape_map './data/umdio-data/umd-building-gis.json'
end

namespace :scrape do
  desc 'Run bus route scrapers'
  task :bus do
    scrape_bus
  end

  desc 'Run course scrapers'
  task :courses do
    # Testudo updated in September for Spring, Fed for fall
    # if fall is updated, we want to get the next year's courses
    year = Time.now.month <= 9 ? Time.now.year : Time.now.year + 1
    years = ((year - 3)..year).to_a.join ' '
    scrape_courses(years)
  end

  desc 'Run course seat updater'
  task :seats do
    semesters = current_and_next_semesters
    sh "ruby app/scrapers/sections_scraper.rb #{semesters.join(' ')}"
  end

  desc 'Run map scraper'
  task :map do
    scrape_map
  end

  desc 'Majors scraper'
  task :majors do
    scrape_majors
  end

  desc 'Scrapes only the current semester courses/sections'
  task :current do
    scrape_courses(current_semester)
  end

  desc 'Scrape a specific semester'
  task :semester, [:sem] do |_task, args|
    scrape_courses(args[:sem])
  end
end

##################################### Dev ######################################

# run with 'rake rubocop' or 'rake rubocop:auto_correct' to apply safe fixes
desc 'Run RuboCop'
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rake'
  task.requires << 'rubocop-rspec'
  task.requires << 'rubocop-sequel'
end
task lint: :rubocop

namespace :dev do

  # docker-compose command with root dev args
  dc = 'docker-compose -f docker-compose-dev.yml'

<<<<<<< HEAD
  desc 'Connect to the database with a SQL shell'
  task :db do
    system "#{dc} exec postgres psql umdio postgres"
  end

=======
>>>>>>> 49710419b4b09f68a4bef8d6273f5cf5f0058c7e
  desc 'Launches the dev environment with docker-compose'
  task :up do
    system "#{dc} up --build -d"
  end

  desc 'Stop and remove the dev environment (containers, networks, volumes, etc)'
  task :down do
    system "#{dc} down"
  end

  desc 'Start existing services previously stopped with dev:stop'
  task :start do
    system "#{dc} start"
  end

  desc 'Stop running services without removing them'
  task :stop do
    system "#{dc} stop"
  end

  desc 'Force a complete rebuild of all containers without using cached layers'
  task :rebuild do
    system "#{dc} build --no-cache --progress tty"
  end
end

#################################### Server ####################################
desc 'Start the web server for dev'
task :up do
  system 'shotgun -p 3000 -o 0.0.0.0'
end
task server: :up

desc 'Start the web server for prod'
task :prod do
  system 'puma -p 3000'
end

desc 'Sinatra console'
task :console do
  system 'bundle exec irb -r ./config.ru'
end
task c: :console

################################### Testing ####################################
desc 'Run tests in /tests that look like *_spec.rb'
RSpec::Core::RakeTask.new :test do |task|
  task.pattern = Dir['tests/**/*_spec.rb']
  task.rspec_opts = '--format documentation' # default to verbose testing, comment for silence
end
task spec: :test

desc 'Run tests in /tests/v1 that look like *_spec.rb'
RSpec::Core::RakeTask.new :testv1 do |task|
  task.pattern = Dir['tests/v1/*_spec.rb']
  task.rspec_opts = '--format documentation' # default to verbose testing, comment for silence
end

desc 'Type check and lint codebase'
task :validate do
  system 'bundle exec solargraph scan', exception: true
  system 'bundle exec solargraph typecheck' # TODO(don): add 'exception: true', right now this breaks
  puts 'validating OpenAPI Spec'
  validate_openapi
  puts 'Spec is valid'
  Rake::Task['rubocop'].execute
end

task default: ['up']
