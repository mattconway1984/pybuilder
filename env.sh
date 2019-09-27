#!/bin/bash

set -e
set -o pipefail

ARGS="$@"
BUILDER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR=$( cd $BUILDER_DIR/../ && pwd)
# To get the name of the current project, run 'python setup.py --name'
# inside a container (the build server may not have python installed).
PROJECT_NAME=$(
    docker run --rm -i -v $PROJECT_DIR:/tmp python:3.6-slim \
    /bin/bash -c "cd /tmp && python setup.py --name")

set -u

# Build the docker container (using the Dockerfile from pybuilder)
docker build $BUILDER_DIR -t $PROJECT_NAME

# If no args are passed, just start the docker container (gives bash prompt)
if [ -z "$ARGS" ]; then
docker run \
    --env PROJECT_NAME=$PROJECT_NAME \
    --rm \
    -v $PROJECT_DIR:/workspace \
    -it \
    --entrypoint /bin/bash \
    $PROJECT_NAME
else
docker run \
    --env PROJECT_NAME=$PROJECT_NAME \
    --rm \
    -i \
    -v $PROJECT_DIR:/workspace \
    $PROJECT_NAME \
    /bin/bash -c "cd /workspace/pybuilder && $ARGS"
fi
