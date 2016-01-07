#!/bin/bash

rvm use 2.1
rvm gemset use rails41
rvmsudo rails s --binding=0.0.0.0 -p 80
