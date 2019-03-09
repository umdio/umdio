# [UMD.io](http://umd.io/) &middot; [![license MIT](https://img.shields.io/github/license/mashape/apistatus.svg)](./LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md#pull-requests)

UMD.io is an open API for the University of Maryland. The main purpose is to allow developers to build awesome tools and projects. In turn, developers can improve the University of Maryland with the things they build.

## Resources

* [Docs](http://umd.io/)
* [Contributing Guide](CONTRIBUTING.md)
* [Facebook Group](https://www.facebook.com/groups/121037971936590/)
* [Twitter](https://twitter.com/UMD_io)

## License

We use the [MIT License](./LICENSE) - do what you want, but don't hold us liable.

## Setting Up Your Environment With Docker
1. [Install docker](https://docs.docker.com/engine/installation/)
2. [Install docker-compose](https://docs.docker.com/compose/install/)
3. Run `docker-compose up`
   * You might need to run docker-related commands with `sudo` if you're a linux user
4. Run the scrapers
    * `docker exec -it umdio_umdio_1 bundle exec rake scrape`
