#!/bin/bash

########################################
#
# This is a script for setting up
# a complete development environment
# of the API Leipzig.
#
# ONLY USE THIS FOR *LOCAL* DEVELOPMENT!
#
# Usage:
#  - Install git, rvm with ruby 1.8.7 and bundler
#  - cd to a directory where you want to create the api folder
#  - Run the script with the following command
#  $ bash < <(curl -s https://raw.github.com/apileipzig/dev/master/setup_dev_env.sh)
#  - If you don't have curl, download it from https://github.com/apileipzig/dev and run it manually
#
########################################

echo "cloning all repositories..."
git clone git@github.com:apileipzig/frontend.git api/
cd api/
if [ ! -d api/ ]; then
  git clone git@github.com:apileipzig/api.git
else
	echo "folder exists! skipping cloning api..."
fi
if [ ! -d panel/ ]; then
  git clone git@github.com:apileipzig/panel.git
else
	echo "folder exists! skipping cloning panel..."
fi
if [ ! -d wiki/ ]; then
  git clone git@github.com:apileipzig/wiki.git
else
	echo "folder exists! skipping cloning wiki..."
fi

echo "invoke rvm..."
which rvm &>/dev/null
if [ $? -eq 0 ]
then
  rvm ree &>/dev/null
	if [ $? -eq 0 ]
	then
		rvm ree
	else
		echo "Ruby Enterprise Edition not found! Trying to install it with rvm..."
		rvm install ree
		rvm ree
	fi
else
	echo "RVM not found. Please install the Ruby Version Manager from here: http://rvm.beginrescueend.com/"
	exit
fi

bundle -v &>/dev/null
if [ $? -ne 0 ]
then
	echo "Bundler not found! Trying to install it..."
	gem install bundler
fi

echo "bundle everything..."
cd api/
bundle --without production
cd ../panel
bundle --without production
cd ../wiki
bundle --without production
cd ..

echo "generating dev files for the api..."
cd api/
echo -e "development:\n  adapter: sqlite3\n  database: db/development.sqlite3\n  pool: 5\n  timeout: 5000" > database.yml
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake permissions:init
bundle exec rake permissions:add:all USER_NAME=admin@apileipzig.de
cd ..

echo "generating dev files for the panel..."
cd panel/
echo -e "development:\n  adapter: sqlite3\n  database: ../api/db/development.sqlite3\n  pool: 5\n  timeout: 5000" > config/database.yml
cd ..
cp -R css/ panel/public/css
cp -R js/ panel/public/js
mkdir -p panel/public/images
cp -R images/* panel/public/images/

echo "generating dev files for the wiki..."
cd wiki/
cd ..
cp -R css/ wiki/public/css
cp -R js/ wiki/public/js
cp -R images/ wiki/public/images/
