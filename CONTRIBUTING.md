# Contributing

## Get Started
`git clone https://github.com/umdio/umdio.git` (or download as a zip, we don't mind!)

## Setting Up Your Environment With Docker
1. [Install docker](https://docs.docker.com/engine/installation/)
2. [Install docker-compose](https://docs.docker.com/compose/install/)
3. Run `docker-compose up`
   * You might need to run docker-related commands with `sudo` if you're a linux user
4. Run the scrapers
    * `docker exec -it umdio_umdio_1 bundle exec rake scrape`

This will take a while, in the meantime, you can read up on our docs here.

Try a few things. Ponder the return of `localhost:3000/v0/courses/sections`.

## Workflow
Edit on your machine in your favorite text editor, and changes will automagically show in your machine's browser, so long as you leave the virtual machine shell open.

Write tests that fail, write code that makes the tests pass. Run tests with `docker exec -it umdio_umdio_1 bundle exec rake` on the VM. If you are running scrapers or managing the database, remember that mongo is running on the VM, so run your scrapers there too.

If you want to see how the server will run with nginx, check `localhost:4080`. From the VM shell, `nginx -s reload` to update. Cool to check this once in a while, like before a commit. (Tough to view the api from your machine's browser, unless you update your hosts file with a line like `api.localhost 127.0.0.1`. This shouldn't really matter, but if you want, it's there.)

## Documentation
We are only as good as our docs.

We're using Jekyll to make managing documentation easier. Edit files in docs/src, then run `jekyll serve` from the docs folder. See your work at `localhost:4000`. Alternatively, you can run `make run` to grab any dependencies and serve, or `make` if you plan to serve the output folder with nginx.

The files in src/<endpoint>/_posts are written in markdown - you specify some metadata, and then write text as you would. Learn more about [markdown syntax](http://daringfireball.net/projects/markdown/syntax) to use all its power.

The files in each endpoint's folder each get rendered on the page as sections. The order of the sections is determined by the date in the name of the file - hence the strange names of the files.

## Read
- [why umdio](https://github.com/umdio/umdio/blob/master/Motivations.md)
- [ideas](https://docs.google.com/document/d/1WQ4w4_HSdkzNP1j0KqrHSYtiU8DEGoXnxHyC5FEp5sY/edit)
- [design](https://docs.google.com/document/d/11uslF3ftvQ3It-NRXs7iRgI34S0MxvqV2S1jioXPcL0/edit?usp=sharing)
- [todo](https://github.com/umdio/umdio/blob/master/Todo.md)

## Read More
Knowledge is power.

- [Sinatra](http://www.sinatrarb.com/)
- [Rack](http://rack.github.io/)
- [MongoDB](http://www.mongodb.org/)
- [RSpec](http://rspec.info/)
- [Nginx](http://nginx.org/en/docs/)
- [Passenger](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html)
- [Jekyll](http://jekyllrb.com/)
- [Docker](https://www.docker.com/)
