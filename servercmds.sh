#!/usr/bin/env/ bash
export IMAGE=$1
export DOCKER_USER=$2
export DPCKER_PWD=$3
echo $DOCKER_PWD | dpcker login -u $DOCKER_USER --password-stdin
docker-compose -f docker-compose.yaml up --detach
echo "sucess"