#!/bin/bash

echo "Creating docker builder env"
tg2sip_builder=$(docker run -v `pwd`:/src -d  -w /src hectorvent/tg2sip-builder:buster tail -f /dev/null)

execute(){
    docker exec $tg2sip_builder $@
}

execute cmake -DCMAKE_BUILD_TYPE=Release .
execute cmake --build .
echo "Build completed"

# Clean
echo "Cleaning docker build env"
docker stop $tg2sip_builder
docker rm $tg2sip_builder
