A very early attempt at an API for UMD data

Status: script scrapes schedule data from testudo and inserts into a mongodb database, sinatra server serves with a limited api. All development is still local, no live server yet.

##TODO:
TDD - write test suite for courses functionality, make sure it's got good coverage
(generally use [best practices](http://blog.carbonfive.com/2013/06/24/sinatra-best-practices-part-one/))
improve: [sanitize queries, return meaningful errors, squash sections results]
write with lambdas or use more helpers - more DRY
implement: [courses/search]

create repo, detail development/contribution process and design specs
create live site

Notes:

- It's worth looking into whether we should be configuring with Rack - would probably make versioning easy as pie, and make it pretty clean to serve the docs and the api, as well as probably making it possible to use different frameworks to serve different endpoints - e.g. courses on Sinatra and buses on Flask
- Should we be using Rspec and/or Cucumber? BDD seems legit, but also, we've got a codebase already... Maybe worth it to start from scratch for v1 and build it actually using BDD


##Contributing: Getting Started
(install homebrew)
install git
install rvm
rvm use ruby
install and set up mongodb
git clone this repo
bundle install
run courses/courses_scraper.rb
run server.rb
check development at localhost:4567

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