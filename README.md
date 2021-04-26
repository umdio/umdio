# [UMD.io](http://umd.io/) &middot; [![license MIT](https://img.shields.io/github/license/mashape/apistatus.svg)](./LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](README.md#Development) [![CI](https://github.com/umdio/umdio/actions/workflows/main.yml/badge.svg)](https://github.com/umdio/umdio/actions/workflows/main.yml) [![codecov](https://codecov.io/gh/umdio/umdio/branch/master/graph/badge.svg?token=d4swAcmOhc)](https://codecov.io/gh/umdio/umdio)

[UMD.io](https://umd.io) is an open API for the [University of Maryland](https://umd.edu). The main purpose is to
give developers easy access to data to build great applications. In turn,
developers can improve the University of Maryland with the things they build.

## Features

Easy API access to

- Four years of course data
- Live Bus data, through NextBus
- Campus Building names and locations
- Information on Professors and Faculty
- Basic info about all Majors

## Getting Started

To use the api, please refer to [our documentation](https://beta.umd.io).

# Development

If you're interested in contributing to UMD.io, please read our [Contributing guide](/CONTRIBUTING.md).
To work on umd.io, or to run your own instance, start by forking and cloning this repo.

## Setting Up Your Environment

First, install [docker](https://docs.docker.com/engine/installation/) and
[docker-compose](https://docs.docker.com/compose/install/). Then, clone the
repo along with the [umdio-data](https://github.com/umdio/umdio-data) submodule.
```sh
git clone --recurse-submodules https://github.com/umdio/umdio.git
```
Then, launch the development environment.
```sh
# You may need to run docker-related commands with `sudo` if you're a linux user
docker-compose -f docker-compose-dev.yml up
```
Once launched, run the scrapers. This will take some time, so in the meantime,
review the rest of the guide.
```sh
# You may need to run `chmod +x umdio.sh`
./umdio.sh scrape
```


## Credits

See [contributors](https://github.com/umdio/umdio/graphs/contributors)

## License

We use the [MIT License](./LICENSE).
