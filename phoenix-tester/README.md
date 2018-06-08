# Dash Testing Image

This Docker image contains all of the necessary elements for testing against the mounted Dash source.  It consists of:

- `Dockerfile` provides definition for the image, based on the bitnami minideb ruby image.
- `Dockerfile.mysql` is a slightly enhanced mysql image with test user access pre-loaded.
- `docker-entrypoint.sh` is the test runner.  It is loosely based on the Circle CI yaml in terms of operations.
- `database.yml` is written to the config directory in the Dash directory to provide database name and user specs.
- `db-setup.sql` is loaded into the mysql image to provide user access by the tests.

## Build

- Building the testing image: `docker build --rm -t _prefix_/phoenix-test:_version_`
- Building the mysql image: `docker build --rm -t _prefix_/phoenix-test-mysql:_version_`

## Run

To run in Kubernetes, use the `phoenix-test` helm chart.  I had problems with volume mounts using minikube, so I used the Kubernetes provided in Docker for Mac (Edge).

The default startup command is `tail -f /dev/null` to keep the container running.  `kubectl exec -it _pod name_ /bin/bash` and run `./docker-entrypoint.sh`.  For Jenkins the command will be overwritten to run `docker-entrypoint.sh` directly.

## Dev Notes

- An attempt was made to use an Alpine base image.  Lack of glibc created some initial issues, the first with `therubyracer`, was resolved by removing it (NodeJS provides the necessary functionality), but additional problems led to box canyons.
- Switched to `frolvlad/alpine-glibc` image, but ran into unresolvable `Grpc error loading shared library ld-linux-x86-64.so.2`.
- Settled on minideb from bitnami.  It has a number of the prerquisites built-in and is smaller.  It is actively maintained.
- Needed a newer installation of chromedriver than is provided from the package. A number of errors went away after it was installed.
- Needed to volume mount /dev/shm to address chromedriver running out of memory during the integration tests.
- `Cannot assign requested address` error due to a `localhost` entry for both `127.0.0.1` and `ipv6` in `/etc/hosts`. `docker-entrypoint` cleans it up prior to running tests.
