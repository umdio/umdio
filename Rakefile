# rakefile
require 'rspec/core/rake_task'
 
RSpec::Core::RakeTask.new :specs do |task|
  task.pattern = Dir['tests/**/*_spec.rb']
end
 
task :default => ['specs']