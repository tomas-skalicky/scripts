#author      :Tomas Skalicky <skalicky.tomas@gmail.com>
#===============================================================================

# Do followings in the folder where this HOW-TO file resides.
# NOTE: Switch to super user is necessary (sudo su --login root)

tag=skalicky/base_ubuntu; docker build --tag="$tag" "$tag"

# Starts a container with a given name.
#   --publish-all       Publishes all ports exposed in Dockerfile to host machine.
#   --interactive=true  Enables me to stop the container with Ctrl+C. It doesn't
#                       work without --tty=true.
#   --tty=true          Enables me to jump out of running Docker container back
#                       to a command line on host machine with Ctrl+C. Note,
#                       without --interactive=true, it doesn't stop the container.
#   --name=<NAME>       Assign a name to the container which makes the interaction
#                       with the container easier.
#                       Moreover, Docker doesn't allow two containers to have
#                       the same name, which prevents mistakes like accidentally
#                       starting two identical ones.
tag=skalicky/oracle_jdk8_tomcat8; docker run --interactive=true --tty=true --publish-all --name=tomcat8_with_jdk8 "$tag":latest

# To see ports of host machine where exposed ports from docker container
# has been mapped to
# Shows a hash of running container
docker ps

# Stops a running container immediately.
docker kill <container_name_or_hash>

# Attaches to a running container with shell.
docker exec --interactive=true --tty=true <container_name_or_hash> bash
# In case you have an issue like "Error opening terminal: unknown."
# (see https://github.com/docker/docker/issues/9299), use
docker exec --interactive=true --tty=true <container_name_or_hash> /bin/bash -c 'export TERM=xterm; export TZ=Europe/Berlin; bash'

