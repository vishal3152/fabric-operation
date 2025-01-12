#!/bin/bash
# stop fabric network of docker-compose for a specified org
# usage: stop-docker.sh <org_name>
# where config parameters for the org are specified in ../config/org.env, e.g.
#   stop-docker.sh netop1
# use config parameters specified in ../config/netop1.env

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; echo "$(pwd)")"
source $(dirname "${SCRIPT_DIR}")/config/setup.sh ${1:-"netop1"} docker

# shutdown fabric network, and cleanup persisent volumes
docker-compose -f ${DATA_ROOT}/network/docker/docker-compose.yaml -f ${DATA_ROOT}/network/docker/docker-compose-ca.yaml down --volumes --remove-orphans

# cleanup chaincode containers and images
docker rm $(docker ps -a | grep dev-peer | awk '{print $1}')
docker rmi $(docker images | grep dev-peer | awk '{print $3}')