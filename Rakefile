# rakefile
require 'rspec/core/rake_task'
 
RSpec::Core::RakeTask.new :specs do |task|
  task.pattern = Dir['tests/**/*_spec.rb']
end
 
desc "Build Database"
task :database_up => ['database_down'] do
  sh 'mongod --dbpath ./data/db --fork --logpath ./data/mongodb.log'
end

desc "shutdown mongo database server"
task :database_down do
  mongo_pid = `pgrep mongod`
  if(!mongo_pid.empty?) then
    puts "DANGER: killing mongod instances: #{mongo_pid}"
    mongo_pid.split("\n").each{|pid| Process.kill(15,pid.to_i)}
  else
    puts 'No mongod processes found -- free to go ahead'
  end
end

desc "Scrape testudo to fill the database"
task :scrape => ['database_up'] do
  ruby 'courses/courses_scraper.rb'
end

desc "Use rack to run the server"
task :server_up => ['server_down','database_up'] do
  puts "Starting server on port:4567. Logs are in data/server.log"
  #this may or may not be good practice. Probably smart to append dates to logs
  sh 'rackup -p 4567 &> ./data/server.log &' 
end

desc "Bring the server down"
task :server_down do #seems like a bad name for this...
  server_pid = `pgrep rackup`
  if(!server_pid.empty?) then
    puts "DANGER: killing rack instances: #{server_pid}"
    server_pid.split("\n").each{|pid| Process.kill(15,pid.to_i)}
  else
    puts "No rack instances running"
  end
end

task :default => ['specs']