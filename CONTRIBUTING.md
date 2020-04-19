# Contributing

## Get Started

`git clone https://github.com/umdio/umdio.git` (or download as a zip, we don't mind!)

## Setting Up Your Environment With Docker

1. [Install docker](https://docs.docker.com/engine/installation/)
2. [Install docker-compose](https://docs.docker.com/compose/install/)
3. Run `docker-compose up`
   - You might need to run docker-related commands with `sudo` if you're a linux user
4. Run the scrapers
   - `docker exec -it umdio_umdio_1 bundle exec rake scrape`

This will take a while, in the meantime, you can read up on our docs here.

Try a few things. Ponder the return of `localhost:3000/v0/courses/sections`.

## Workflow

Edit on your machine in your favorite text editor, and changes will automagically show in your machine's browser, so long as you leave the virtual machine shell open.

Write tests that fail, write code that makes the tests pass. Run tests with `docker exec -it umdio_umdio_1 bundle exec rake` on the VM. If you are running scrapers or managing the database, remember that mongo is running on the VM, so run your scrapers there too.

## Documentation

We are only as good as our docs.

We're using Jekyll to make managing documentation easier. Edit files in docs/src, then run `jekyll serve` from the docs folder. See your work at `localhost:4000`. Alternatively, you can run `make run` to grab any dependencies and serve, or `make` if you plan to serve the output folder with nginx.

The files in src/<endpoint>/\_posts are written in markdown - you specify some metadata, and then write text as you would. Learn more about [markdown syntax](http://daringfireball.net/projects/markdown/syntax) to use all its power.

The files in each endpoint's folder each get rendered on the page as sections. The order of the sections is determined by the date in the name of the file - hence the strange names of the files.

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

## Read

- [why umdio](https://github.com/umdio/umdio/blob/master/Motivations.md)
- [ideas](https://docs.google.com/document/d/1WQ4w4_HSdkzNP1j0KqrHSYtiU8DEGoXnxHyC5FEp5sY/edit)

## Read More

- [Sinatra](http://www.sinatrarb.com/)
- [Rack](http://rack.github.io/)
- [RSpec](http://rspec.info/)
- [Nginx](http://nginx.org/en/docs/)
- [Docker](https://www.docker.com/)
