#!/bin/bash

git pull
git submodule update --init --recursive
rvm use ruby-2.1.7
bundle install --deployment --without development test
bundle exec rake assets:precompile db:migrate RAILS_ENV=production
bundle exec whenever -i
passenger-config restart-app $(pwd)
