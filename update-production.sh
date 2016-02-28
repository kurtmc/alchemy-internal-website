#!/bin/bash

# Pull latest
git pull
git submodule update --init --recursive

# Update systemd services
sudo cp systemd-services/pdf-files.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable pdf-files.service
sudo sysetmctl restart pdf-files.service

# Rails
rvm use ruby-2.1.7
bundle install --deployment --without development test
bundle exec rake assets:precompile db:migrate RAILS_ENV=production
bundle exec whenever -i
passenger-config restart-app $(pwd)
