#An API for UMD data 
####Development is under way!

Status: script scrapes schedule data from testudo and inserts into a mongodb database, sinatra serves courses endpoint. Bundler and rake manage the tasks, and rspec testing has limited coverage.

##TODO:
- Testing - write more comprehensive tests (aka, Who Can Break The Most Things!?)
  - more specific examples
  - negative tests (should get nothing)
  - need coverage for: root, bad url catcher route
  - current tests do not cover lots of non-implemented parts of API-niceness, e.g. helping out when the developer types /Sections instead of /sections
  - possible that we could test methods individually and smoke test the abstract levels - when the test suite runs too long. (stories are told of 30-minute test suites, so we aren't there yet, at 2.5s)
- Implement:
  - sanitize queries
  - return meaningful errors on malformed queries (currently returning null, as malformed queries miss the database)
  - add parameter capability (e.g. /courses/ENES100?semester=201501)
  - allow limits and filters -- projection stuff
	- courses/search
	- courses/<dep>
paginate responses (just for searches?)
- Create live site with docs + api
- Add to the design specs, documentation, api
- optimizations: gzip and cache responses (eventually, we might move to metadata + pagination)

Meta: find developers and projects, eat more databases, build core team, think about long term (license, technology, team structure)

##Contributing: Getting Started
Depending on where you are starting from, should take between 10 minutes and forever

-  (mac) install [xcode command line tools](https://developer.apple.com/xcode/) (or `xcode-select --install` from the command line)
- (mac) install [homebrew](http://brew.sh/)
- install [git](http://git-scm.com/) (or `brew install git`)
- install [rvm](https://rvm.io/rvm/install)
- install ruby 2.1.1 and switch rubies `rvm use 2.1.1`
- install [mongodb](http://docs.mongodb.org/manual/installation/)
- git clone this repo `git clone https://github.com/umdio/umdio my_umdio_app_folder`
- install and build all the dependencies `bundle install`

Warning! If you are running other mongodb databases or rack servers, don't use the rake commands

- build the database `bundle exec rake setup`
- start a local server `bundle exec rake server_up`
- run the test suite `bundle exec rake`
- check development at localhost:4567
- terminate server with `bundle exec rake server_down`

If you get sick of typing `bundle exec rake` all the time, alias it to something short like `r`.

##Contributing:Development Workflow
- Design the endpoint you want to create, e.g. /bus
- Write initial 'hello world' tests, they should fail
- Create a bus folder with bus.rb and bus_helpers.rb, using the module structure from similar files (see courses)
- require and register your module in server.rb
- add routes of the form "app.get '/<endpoint>'""  to the module
- add hello world code, hello world tests should pass

write tests --> add functionality --> make tests pass --> write tests

##Contributing:Read more
- [Design doc](https://docs.google.com/document/d/11uslF3ftvQ3It-NRXs7iRgI34S0MxvqV2S1jioXPcL0/edit?usp=sharing)
- [Sinatra](http://www.sinatrarb.com/)
- [Rack](http://rack.github.io/)
- [MongoDB](http://www.mongodb.org/)
- [RSpec](http://rspec.info/)


###Notes:

- It's worth looking into whether we should be configuring with Rack - would probably make versioning easy as pie, and make it pretty clean to serve the docs and the api, as well as probably making it possible to use different frameworks to serve different endpoints - e.g. courses on Sinatra and buses on Flask
- Should we be using Rspec and/or Cucumber? BDD seems legit, but also, we've got a codebase already... Maybe worth it to start from scratch for v1 and build it actually using BDD