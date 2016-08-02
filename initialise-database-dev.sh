#!/bin/bash
source /usr/local/rvm/scripts/rvm
cd /var/alchemy
bundle exec rake assets:precompile db:migrate db:seed RAILS_ENV=development
