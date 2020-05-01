#!/bin/bash

cd /home/app/avalon
export HOME=/home/app

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
nvm install 10.19.0
nvm use 10.19.0


# Workaround from https://github.com/yarnpkg/yarn/issues/2782
yarn install

bundle install && \
cp config/controlled_vocabulary.yml.example config/controlled_vocabulary.yml

rm -f tmp/pids/server.pid
bundle exec rake db:migrate

