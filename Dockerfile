FROM ruby:3.0

WORKDIR /api
COPY . /api
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs && \
    bundle install
