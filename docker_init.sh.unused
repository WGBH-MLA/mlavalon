#!/bin/bash

cd /home/app/avalon
export HOME=/home/app

apt-get -y install git nodejs yarn libxslt1-dev libpq-dev build-essential ruby-dev libxml2-dev dumb-init



# Workaround from https://github.com/yarnpkg/yarn/issues/2782
yarn install

bundle config build.nokogiri --use-system-libraries && \
bundle install && \
cp config/controlled_vocabulary.yml.example config/controlled_vocabulary.yml

rm -f tmp/pids/server.pid
bundle exec rake db:migrate

