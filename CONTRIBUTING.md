# Contributing to UMD.io

Thank you for taking time to contribute! UMD.io is run and built by a community
of volunteer developers, and its people like you who help make it possible.

## Table of Contents

- [Contributing to UMD.io](#contributing-to-umdio)
  - [Table of Contents](#table-of-contents)
  - [Getting Started](#getting-started)
  - [Setup](#setup)
  - [Documentation](#documentation)
    - [Development Tasks](#development-tasks)
    - [Code Style](#code-style)
    - [Tech Stack](#tech-stack)
  - [Adding New Data](#adding-new-data)
  - [Logging](#logging)
  - [Testing](#testing)

## Getting Started

You should start by creating your own fork of UMD.io to work on locally. Then,
check out some of these resources:

- Join our [Discord Community](https://discord.gg/V4FF4jMJEc) for support and updates
- Check our [issues backlog](https://github.com/umdio/umdio/issues) to see what
  needs to be done. Issues wit the ["good first issue"](https://github.com/umdio/umdio/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
  tag are particularly good places to start.
- Check out the [projects board](https://github.com/umdio/umdio/projects) and open [pull requests](https://github.com/umdio/umdio/pulls) to see what other contributors are currently working on
- Familiarize yourself with the codebase by reading the below [documentation section](#documentation),
  reading the published [API Docs](https://beta.umd.io), and reading through the
  [source code](https://github.com/umdio/umdio/tree/master/app).

To submit your changes to this repository, submit a [pull requests](https://github.com/umdio/umdio/pulls)
to the `master` branch. We'll give it a review, and once it looks good and no
tests are failing, we will merge it into the main codebase.

## Setup

Additionally, while not strictly required, it is a good idea to have Ruby
installed locally. Although Ruby is not required to run the application because
of the use of Docker containers, you will need it to run [development tasks](#development-tasks). We _strongly_ recommend using [RVM](https://rvm.io/) over
installing Ruby directly.

If you choose to install Ruby, you can finish setting up your local environment
by running
```sh
rvm use --install ruby-2.7.2 # Should be the same version used in Gemfile
gem install bundler   # Project-level gem management. https://bundler.io/
rvm docs generate     # Build docs for ruby stdlib and global gems
bundle exec yard gems # Build docs for local gems
```

## Documentation

For the public-facing API, we use [OpenAPI v3](https://swagger.io/docs/specification/about/)
to document everything. You can view our spec
[here](https://github.com/umdio/umdio/blob/master/openapi.yaml). The docs are
served with [ReDoc](https://github.com/Redocly/redoc) and are automatically built
on every tagged commit.

If you're actively working on the documentation, use the `docker-compose-dev.yml`
file to view your changes live in ReDoc, on `http://localhost:8080`.

```sh
rake dev:up
# If rake throws a LoadError (e.g. "LoadError: cannot load such file -- rspec/core/rake_task"),
# try running the task below instead. You may need to run `bundle install` beforehand.
sudo -E rake dev:up
```

### Development Tasks
We use [Rake](https://github.com/ruby/rake) for running tasks. A comprehensive list of tasks can be found by running `bundle exec rake -T`.

Some of the more important, highly used tasks are

```sh
rake dev:up   # Launch the development environment with docker-compose
rake dev:down # Stops the development environment and removes its containers, networks, etc.
rake scrape   # Run all scrapers
rake validate # Type check and lint the codebase with solargraph and rubocop
rake rubocop:auto_correct # Run rubocop and apply all safe fixes
```

You can easily run rake tasks within the development environment with the `umdio.sh`
script. All this script does is forward its arguments to `rake` running on the `umdio`
container, making this script effectively a drop-in replacement for running `rake`.

### Code Style

Within the codebase, comments and [good practices](https://rubystyle.guide/) are
encouraged. We use [Rubocop](https://rubocop.org/) to enforce code style.

All [rake](https://ruby.github.io/rake/) tasks should have descriptions.
### Tech Stack

umd.io runs on Ruby, with various libraries such as [Rack](https://github.com/rack/rack),
[Sinatra](http://sinatrarb.com/), [Puma](https://puma.io/), and
[Sequel](https://github.com/jeremyevans/sequel). We use
[PostgreSQL](https://www.postgresql.org/) as the database. Everything runs in
[Docker](https://www.docker.com/).

## Adding New Data

If you're interested in adding a new endpoint, here's a rough guide on how to do it. Our data for `majors` is a great, simple example.

1. Create a model in `/app/models`. We use [Sequel](https://github.com/jeremyevans/sequel) on top of Postgres. It should include a `to_v1` method that translates whatever is in your table into the object you want to return.
2. Create a scraper in `/app/scrapers`. This is to populate the table for the model you just created.
   - If you're scraping a live webpage, `courses_scraper.rb` might be a good resource. We use nokogiri to parse HTML.
   - If you're parsing a JSON file, consider adding it to [umdio-data](https://github.com/umdio/umdio-data), and creating an importer, such as `map_scraper.rb`. (NOTE: umdio-data is now included as a submodule; so this scraper should be updated)
3. Create a controller in `/app/controllers`. Add endpoints as you see fit.
4. Register the controller in `server.rb`.
5. Write documentation in `openapi.yaml`.
6. Add a test suite in the `tests/` folder.

## Logging

We use Ruby's built-in logger to output messages to standard output. Learn more
about [Ruby's logging module](https://ruby-doc.org/stdlib-2.1.0/libdoc/logger/rdoc/Logger.html)

Here's an example of output from the courses scraper:

```
[2018-10-18 01:35:01] INFO  (courses_scraper): Searching for courses in term 201801
[2018-10-18 01:35:02] INFO  (courses_scraper): 178 department/semesters so far
[2018-10-18 01:35:02] INFO  (courses_scraper): Searching for courses in term 201805
[2018-10-18 01:35:03] INFO  (courses_scraper): 301 department/semesters so far
```

The formatting for outputted messages is as follows:`[DATE TIME] LOG_LEVEL (PROGRAM_NAME): {MESSAGE}`

An example of a log call in ruby:
```ruby
logger.info(prog_name) {"MESSAGE"}
```

You should use Ruby's built-in log-levels where appropriate, when displaying
errors you should use logger.error, when displaying information you should use
`logger.info`, and so on.

Our logger implementation is located at the `scraper_common.rb` file located at
`$app/scrapers/scraper_common.rb`

## Testing

We use [RSpec](https://rspec.info/) to test. You can find the tests in the
`tests` directory. Please make sure any new features you add have test cases to go along with them. Pull requests that do not include test cases may not be
accepted.

To run the tests, run the following:
```sh
# Make sure the development environment is up
rake dev:up
# Populate the database with test data
./umdio.sh test_scrape
# Run all tests
./umdio.sh test
# Only run v1 test cases
./umdio.sh testv1
```
