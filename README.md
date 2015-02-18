An API for UMD data - development is under way!

Status: script scrapes schedule data from testudo and inserts into a mongodb database, sinatra serves courses endpoint. Bundler and rake manage the tasks, and rspec testing has limited coverage

##TODO:
Testing - write more comprehensive tests
Implement: courses/search, courses/<dep_number>
sanitize queries & return meaningful errors on malformed queries (currently returning null, as malformed queries miss the database)
add parameter capability (e.g. /courses/ENES100?semester=201501)
  allow limits and filters -- projection stuff
paginate responses (just for searches?)
add database config to the rakefile, so we're really easy to duplicate

push to repo!
create live site with docs + api

Add to the design specs, documentation 

##Contributing: Getting Started
(install homebrew)
install git
install rvm
rvm use 2.1.1
[install and run mongodb](http://docs.mongodb.org/manual/installation/)
git clone this repo
bundle install
bundle exec rake database_up
bundle exec rake scrape
bundle exec rake server_up
bundle exec rake
check development at localhost:4567
terminate server with bundle exec rake server_down


##Contributing:Development Workflow
design the endpoint you want to create, i.e /bus
write initial 'hello world' tests, they should fail
create a bus folder with bus.rb and bus_helpers.rb, using the module structure from similar files (see courses)
require and register your module in server.rb
add routes of the form "app.get '/<endpoint>'""  to the module
add hello world code, hello world tests should pass
write tests <--> add functionality

##Contributing:Read more
You'll probably be referencing the docs for sinatra as well as the ruby-mongo driver a lot, especially at first, on top of the api design doc.
Also how to test with rack

###Notes:

- It's worth looking into whether we should be configuring with Rack - would probably make versioning easy as pie, and make it pretty clean to serve the docs and the api, as well as probably making it possible to use different frameworks to serve different endpoints - e.g. courses on Sinatra and buses on Flask
- Should we be using Rspec and/or Cucumber? BDD seems legit, but also, we've got a codebase already... Maybe worth it to start from scratch for v1 and build it actually using BDD
