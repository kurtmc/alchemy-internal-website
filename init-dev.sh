#!/bin/bash

RUBY_VERSION=2.1
RAILS_VERSION=4.1.16
DEPENDS="git gnupg which tar findutils procps nodejs"

# Update
dnf -y update

# Install dependencies
dnf install -y ${DEPENDS}

# Install RVM, ruby and rails
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash
source /usr/local/rvm/scripts/rvm
rvm install ${RUBY_VERSION}
rvm --default use ${RUBY_VERSION}
gem install --no-document rails -v ${RAILS_VERSION}

# Install app
cd /var/alchemy
bundle install
cp database.yml.example config/database.yml
cp secrets.yml.example config/secrets.yml
