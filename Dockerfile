FROM ruby:2.4.1

# prepare env
USER root
ENV HOME /root
ENV APP_ROOT /usr/src/app
WORKDIR $APP_ROOT

# copy product code
COPY . $APP_ROOT

# bundle install
RUN bundle install

# install javascript runtime and sqlite3 for rails
RUN apt-get update -qq && apt-get install -y build-essential nodejs sqlite3
