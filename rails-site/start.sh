#!/bin/bash
source ~/.rvm/scripts/rvm
DATABASE_CONFIG=database.yml
if [ ! -f $DATABASE_CONFIG ]; then
	    echo "$DATABASE_CONFIG not found!"
	    exit 1
fi
cp $DATABASE_CONFIG config/

rvm use 2.1
rvm gemset use rails41
rvmsudo rails s --binding=0.0.0.0 -p 80
