#!/bin/bash
source /usr/local/rvm/scripts/rvm
cd /var/alchemy
RAILS_ENV=development bundle exec passenger start
