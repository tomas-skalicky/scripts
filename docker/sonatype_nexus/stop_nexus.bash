#!/usr/bin/env bash
#author      :Tomas Skalicky <skalicky.tomas@gmail.com>
#===============================================================================

###
#
# Stops a running Sonatype Nexus and removes the container.
#
###

#-------------------------------------------------------------------------------

set -e

#-------------------------------------------------------------------------------

source ./common

#-------------------------------------------------------------------------------

printf 'INFO: %s\n' "Stopping ${container_name:?} container"
docker stop "$container_name" >/dev/null

printf 'INFO: %s\n' "Removing $container_name container"
docker rm "$container_name" >/dev/null

if nexus_container_exists; then
    printf 'ERROR: %s\n' "$container_name container still exists"
    exit 2
fi

#-------------------------------------------------------------------------------

