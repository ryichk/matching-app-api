# Matching App API README

This README would normally document whatever steps are necessary to get the
application up and running.

## Set Up

```sh
$ docker-compose up -d
```

## Database initialization

```sh
$ docker-compose run --rm api bundle exec rails db:prepare
```

## Run bundle install

```sh
$ docker-compose run --rm api bundle install
```
## How to run the test suite

```sh
$ docker-compose run --rm api bin/rspec
```
