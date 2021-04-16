# [UMD.io](http://umd.io/) &middot; [![license MIT](https://img.shields.io/github/license/mashape/apistatus.svg)](./LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](README.md#Development)

UMD.io is an open API for the University of Maryland. The main purpose is to give developers easy access to data to build great applications. In turn, developers can improve the University of Maryland with the things they build.

## Features

Easy API access to

- Three years of course data
- Live Bus data, through NextBus
- Campus Building names and locations
- Basic info about all Majors

## Getting Started

To use the api, please refer to [our documentation](https://beta.umd.io).

# Development

To work on umd.io, or to run your own instance, start by forking and cloning this repo.

## Setting Up Your Environment With Docker

1. [Install docker](https://docs.docker.com/engine/installation/)
2. [Install docker-compose](https://docs.docker.com/compose/install/)
3. Run `docker-compose up`
   - You might need to run docker-related commands with `sudo` if you're a linux user
4. Run the scrapers `./umdio.sh scrape`
   - You might need to `chmod +x umdio.sh`

This will take some time, so in the meantime, review the rest of the guide.

## Documentation

Within the codebase, comments and [good practices](https://rubystyle.guide/) are encouraged, and will later be enforced.

For the public-facing API, we use [OpenAPI v3](https://swagger.io/docs/specification/about/) to document everything. You can view our spec [here](https://github.com/umdio/umdio/blob/master/openapi.yaml). The docs are served with [ReDoc](https://github.com/Redocly/redoc) and are automatically built on every tagged commit.

If you're actively working on the documentation, use the `docker-compose-dev.yml` file to view your changes live in ReDoc, on `http://localhost:8080`.

```
docker-compose -f docker-compose-dev.yml up
```

## Tech Stack

umd.io runs on Ruby, with various libraries such as Rack, Sinatra, Puma, and Sequel. We use Postgresql as the database. Everything runs in docker.

## Adding new data
If you're interested in adding a new endpoint, here's a rough guide on how to do it. Our data for `majors` is a great, simple example.
1. Create a model in `/app/models`. We use [Sequel](https://github.com/jeremyevans/sequel) on top of Postgres. It should include a `to_v1` method that translates whatever is in your table into the object you want to return.
2. Create a scraper in `/app/scrapers`. This is to populate the table for the model you just created.
   - If you're scraping a live webpage, `courses_scraper.rb` might be a good resource. We use nokogiri to parse HTML.
   - If you're parsing a JSON file, consider adding it to [umdio-data](https://github.com/umdio/umdio-data), and creating an importer, such as `map_scraper.rb`. (NOTE: umdio-data is now included as a submodule; so this scraper should be updated)
3. Create a controller in `/app/controllers`. Add endpoints as you see fit.
4. Register the controller in `server.rb`.
5. Write documentation in `openapi.yaml`

## Logging

We use Ruby's built-in logger to output messages to standard output. Learn more about [Ruby's logging module](https://ruby-doc.org/stdlib-2.1.0/libdoc/logger/rdoc/Logger.html)

Here's an example of output from the courses scraper:

```
[2018-10-18 01:35:01] INFO  (courses_scraper): Searching for courses in term 201801
[2018-10-18 01:35:02] INFO  (courses_scraper): 178 department/semesters so far
[2018-10-18 01:35:02] INFO  (courses_scraper): Searching for courses in term 201805
[2018-10-18 01:35:03] INFO  (courses_scraper): 301 department/semesters so far
```

The formatting for outputted messages is as follows:`[DATE TIME] LOG_LEVEL (PROGRAM_NAME): {MESSAGE}`

An example of a log call in ruby:
`logger.info(prog_name) {"MESSAGE"}`

You should use Ruby's built-in log-levels where appropriate, when displaying errors you should use logger.error, when displaying information you should use logger.info, and so on.

Our logger implementation is located at the `scraper_common.rb` file located at `$app/scraper_common.rb`

## Testing

We use rspec to test. You can find the tests in the `tests` directory. Run tests with `./umdio.sh test`.

## Credits

See [contributors](https://github.com/umdio/umdio/graphs/contributors)

## License

We use the [MIT License](./LICENSE).
