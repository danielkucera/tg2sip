#!/bin/bash

DOCKER_IMAGE=hectorvent/tg2sip-builder

for DOCKER_TAG in bionic buster
# for DOCKER_TAG in bionic buster centos6 centos7
do
    docker build . -f Dockerfile."$DOCKER_TAG" -t "$DOCKER_IMAGE:$DOCKER_TAG"
    docker push "$DOCKER_IMAGE:$DOCKER_TAG"
done
