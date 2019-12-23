#!/usr/bin/env bash
#author      :Tomas Skalicky <skalicky.tomas@gmail.com>
#===============================================================================

###
#
# Set up according to https://hub.docker.com/r/sonatype/nexus/
#
###

#-------------------------------------------------------------------------------

set -e

#-------------------------------------------------------------------------------

source ./common

#-------------------------------------------------------------------------------

host_port=9180
container_port=8081
image_name=sonatype/nexus:oss

printf 'INFO: %s\n' "Starting ${container_name:?} container"
docker run \
           --detach=true \
           --publish="$host_port":"$container_port" \
           --volume=/opt/sonatype_nexus/storage:/sonatype-work/storage \
           --name="$container_name" \
           "$image_name" >/dev/null

#-------------------------------------------------------------------------------

printf 'INFO: %s\n' "Started $container_name container:"
docker ps --filter=name="$container_name"

#-------------------------------------------------------------------------------

