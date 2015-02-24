#An API for UMD data 
####Development is under way!

Status: script scrapes schedule data from testudo and inserts into a mongodb database, sinatra serves courses endpoint. Bundler and rake manage the tasks, and rspec testing has limited coverage. Nginx will live on the server, serve the static files for the docs, remove trailing slashes, and serving cached responses. nginx config will live on the server, so that's not here. You don't need to worry about it to develop though.

##TODO:
- Testing - write more comprehensive tests (aka, Who Can Break The Most Things!?)
  - negative tests (should get nothing)
  - need coverage for: root, bad url catcher route
  - current tests do not cover lots of non-implemented parts of API-niceness, e.g. helping out when the developer types /Sections instead of /sections
  - possible that we could test methods individually and smoke test the abstract levels - when the test suite runs too long. (stories are told of 30-minute test suites, so we aren't there yet, at 2.5s)
- Implement:
  - sanitize queries - case insensitive, only 'allowed' url characters, smart catching close things
  - return meaningful errors on malformed queries (currently returning null, as malformed queries miss the database)
  - add parameter capability (e.g. /courses/ENES100?semester=201501)
  - allow limits and filters -- projection stuff
	- courses/search
	- courses/<dep>
  - api root - object list of endpoints, with some metadata?
paginate responses (just for searches?)
- Create live site with docs + api
- Add to the design specs, documentation, api
- optimizations: gzip and cache responses (eventually, we might move to metadata + pagination)
- [Nginx to remove trailing slashes](http://www.nginxtips.com/add-trailing-slash-nginx/) or [Rack](https://github.com/jtrupiano/rack-rewrite)

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
- start a local server `bundle exec rake up`
- run the test suite `bundle exec rake`
- check development at localhost:3000

If you get sick of typing `bundle exec rake` all the time, alias it to something short like `r`.

- Stop and start the database with `bundle exec rake database:down` and `bundle exec rake database:up`

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
- Security: 
  - In production, we probably shouldn't have a rake task running mongo - it should be a separate user with only those permissions
  - We should set up the server firewall to only accept certain connections
  - We should use strong passwords and keep them secure
  - We should thoroughly test our system's security from the beginning, and have evidence that we are secure - that way, more people can trust us with their data.
  - Eventually, a single API for UMD data is much less vulnerable than a thousand separate databases everywhere - do it right once, enforce it strictly, then you only have one thing to worry about. Defense in depth, lock everything tight. Open is more secure than closed, because you have more eyes on it.
