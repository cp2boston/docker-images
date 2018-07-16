#!/bin/bash -e

# NOTE: This will operate on the mounted source volume.  If you would prefer to leave
#       the source alone, copy it to an internal directory and change the SOURCEDIR
#       variable during the Docker run, e.g. -e SOURCEDIR=<source directory>

# copy a docker specific database.yml. If this is running in the k8s test, modify the
# database host to be the provided name.
if [ ! -z ${PHOENIX_TEST_DB_HOST} ]; then
    sed -i "s/localhost/${PHOENIX_TEST_DB_HOST}/" database.yml
fi
cp database.yml ${SOURCEDIR}/config/database.yml

# update /etc/hosts so that it doesn't contain a double entry for localhost.  This
# causes a problem with resque being able to assign a requested address.  The copy
# is because the write in place fails with /etc/hosts.
sed 's/::1\tlocalhost/::1\t/' /etc/hosts > hosts && cp hosts /etc/hosts

# downgrade ruby to 2.3.3 to match the default for debian:stretch
sed -i "s/ruby '2.3.7'/ruby '2.3.3'/" /source/Gemfile

# so that the rspec run will find the attached redis
export REDIS_URL=redis://${REDIS_SERVICE_HOST}

# setup
cd ${SOURCEDIR}

bundle check || bundle install --jobs=4 --retry=3
yarn add --force node-sass
# tests
yarn test
coffeelint -r app/assets/javascripts -f coffeelint.json
bundle exec rubocop
node_modules/webpack/bin/webpack.js
RAILS_ENV=test bundle exec rake db:create db:schema:load --trace
RAILS_ENV=test bundle exec rake db:migrate:redo VERSION=20180510170950
# Not all of the spec paths match the **/*.rb pattern.  In those cases I have reduced it to the directory
echo $'------------------\nTesting models ...'
bundle exec rspec --format progress --format documentation --out ${SOURCEDIR}/tmp/models_results.html spec/models/**/*.rb
echo $'------------------\nTesting controllers ...'
bundle exec rspec --format progress --format documentation --out ${SOURCEDIR}/tmp/controllers_results.html spec/controllers/**/*.rb
echo $'------------------\nTesting services ...'
bundle exec rspec --format progress --format documentation --out ${SOURCEDIR}/tmp/services_results.html spec/services/**/*.rb
echo $'------------------\nTesting jobs ...'
bundle exec rspec --format progress --format documentation --out ${SOURCEDIR}/tmp/jobs_results.html spec/jobs/**/*.rb
echo $'------------------\nTesting mailers ...'
bundle exec rspec --format progress --format documentation --out ${SOURCEDIR}/tmp/mailers_results.html spec/mailers
echo $'------------------\nTesting others ...'
bundle exec rspec --format progress --format documentation --out ${SOURCEDIR}/tmp/others_results.html spec/others
echo $'------------------\nTesting serializers ...'
bundle exec rspec --format progress --format documentation --out ${SOURCEDIR}/tmp/serializers_results.html spec/serializers
echo $'------------------\nTesting integration ...'
bundle exec rspec --format progress --format documentation --out ${SOURCEDIR}/tmp/integration_results.html spec/integration/**/*.rb
echo $'------------------\n-- Complete --'