#!/bin/bash

set -e
set -o pipefail

ARGS="$@"
BUILDER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR=$( cd $BUILDER_DIR/../ && pwd)
IMAGE_NAME=$(docker run --rm -i -v $PROJECT_DIR:/tmp python:3.6-slim /bin/bash -c "cd /tmp && python setup.py --name")

# If no artifactory credentials are supplied, then setup some rubbish ones to
# allow developers to run "make wheel/test" locally etc. Won't be able to
# publish, but that's okay because only Jenkins should publish artifacts.
if [ -z "$ARTIFACTS_USER" ]; then
    ARTIFACTS_USER="nobody"
fi
if [ -z "$ARTIFACTS_TOKEN" ]; then
    ARTIFACTS_TOKEN="empty"
fi
if [ -z "$ARTIFACTORY_INDEX" ]; then
    ARTIFACTORY_INDEX="none"
fi

# If no SAMBA credentials are supplied, then setup some rubbish ones to allow
# developers to run "make wheel/test" locally etc. Won't be able to publish docs
# locally, but that's okay because only Jenkins should publish docs.
if [ -z "$SMB_USER" ]; then
    SMB_USER="nobody"
fi
if [ -z "$SMB_PASSWORD" ]; then
    SMB_PASSWORD="none"
fi

set -u

docker build $BUILDER_DIR -t $IMAGE_NAME

# If no args are passed, just start the docker container
if [ -z "$ARGS" ]; then
docker run \
    --env PROJECT_NAME=$IMAGE_NAME \
    --rm \
    -v $PROJECT_DIR:/workspace \
    -it --entrypoint /bin/bash $IMAGE_NAME
else
docker run \
    --env TWINE_USERNAME=$ARTIFACTS_USER \
    --env TWINE_PASSWORD=$ARTIFACTS_TOKEN \
    --env TWINE_REPOSITORY_URL=$ARTIFACTORY_INDEX \
    --env SAMBA_USERNAME=$SMB_USER \
    --env SAMBA_PASSWORD=$SMB_PASSWORD \
    --env PROJECT_NAME=$IMAGE_NAME \
    --rm -i -v $PROJECT_DIR:/workspace \
    $IMAGE_NAME /bin/bash -c "cd /workspace/builder && $ARGS"
fi
