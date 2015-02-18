# rakefile
require 'rspec/core/rake_task'
 
RSpec::Core::RakeTask.new :specs do |task|
  task.pattern = Dir['tests/**/*_spec.rb']
end
 
desc "Build Database"
task :database do
  #currently, the only thing to do to build the database is run the scraper
  #you need to have mongodb running already
  ruby 'courses/courses_scraper.rb' #should do this only if it is not already built, if it's updated, run 
end

task :server do
  sh 'rackup -p 4567'
end

task :default => ['specs']