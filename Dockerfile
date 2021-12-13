FROM ruby:2.7

RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /umdio/
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN bundle config set without 'development,test' && \
    bundle config set frozen 'true'


ADD Gemfile* $APP_HOME
# RUN bundle install --frozen --without development,test
RUN bundle install

ADD . $APP_HOME
