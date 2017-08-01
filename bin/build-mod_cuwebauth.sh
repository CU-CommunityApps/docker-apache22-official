#!/bin/bash

BUILD_TAG="dtr.cucloud.net/cs/apache22-official:cuwabuild-tmp"
CONTAINER_NAME=${BUILD_TAG//[\/:.]}
CUWA_VERSION="2.3.0.238"

set -e

[[ ! -z "${1}" ]] && CUWA_VERSION="${1}"

# Make sure someone didn't cd into bin/, or call me from a completely different path
BASEDIR=$(dirname "${0}")"/../"

echo Updating mod_cuwebauth.so to version ${CUWA_VERSION}

set -x

docker build \
       --build-arg CUWA_VERSION=${CUWA_VERSION} \
       -f ${BASEDIR}Dockerfile.cuwa-build \
       --force-rm \
       --pull \
       -t ${BUILD_TAG} \
       ${BASEDIR}

# Will generate error if you already have a container named ${CONTAINER_NAME}
# Most likely scenario would be a previous failed build attempt.
docker create \
       --name ${CONTAINER_NAME} \
       ${BUILD_TAG}

# Copy module from build container to the previously-determined base directory.
docker cp ${CONTAINER_NAME}:/usr/local/apache2/modules/mod_cuwebauth.so ${BASEDIR}lib/

# Clean up
docker rm ${CONTAINER_NAME}
docker rmi ${BUILD_TAG}
