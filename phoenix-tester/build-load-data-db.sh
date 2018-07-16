#!/bin/bash

# Script to run the load data seeding against the attached mysql database

export SEEDS_ADD_LOAD_TEST_DATA=true

# Copy the mounted source to a temporary directory
cp -r /source/. src

# Replace the localhost entries in database.yml with db (the name of the attached database)
# and copy it to the src/config directory for the rake operation
sed -i "s/localhost/${DB_HOST:-db}/" database.yml
cp database.yml ./src/config

cd ./src
# Make sure the gems are up to date
bundle install --jobs=4 --retry=3

# Create the database and populate it with the default seeds as well as the load test data
rake db:reset

# Generate msysql dump
mysqldump -u wf-user -pwfpwd -h db wellframe-development > /db-output/loadtest.sql
