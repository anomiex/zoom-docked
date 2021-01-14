#!/bin/bash

set -eo pipefail

. /usr/share/zoom-docked/docker-shared.sh

# Docker will have created /home/$USER_NAME as root to mount
# the volumes. Fix that, and create ~/.config.
mkdir -p "$USER_HOME/.config/"
chown "$USER_UID:$USER_GID" --from=0:0 "$USER_HOME"
chown "$USER_UID:$USER_GID" --from=0:0 "$USER_HOME/.config"

# Create the user and group.
addgroup --quiet --gid "$USER_GID" "$USER_NAME"
adduser --quiet --disabled-login --uid "$USER_UID" --gid "$USER_GID" \
	--no-create-home --home="$USER_HOME" \
	--gecos 'Zoom' "$USER_NAME"

# Add to video and audio groups, for access to video and audio devices.
quietly adduser --quiet "$USER_NAME" video
quietly adduser --quiet "$USER_NAME" audio

# Copy zoomus.conf into position. Zoom tries to update it by renaming, which doesn't work for a file bind mount.
[[ -e "$USER_HOME/.zoom-docked/zoomus.conf" ]] && cp -a "$USER_HOME/.zoom-docked/zoomus.conf" "$USER_HOME/.config/zoomus.conf"

# Copy zoomus.conf back on exit
function uncopyconf {
	[[ -e "$USER_HOME/.config/zoomus.conf" ]] && cp -a "$USER_HOME/.config/zoomus.conf" "$USER_HOME/.zoom-docked/zoomus.conf"
}
trap uncopyconf SIGINT SIGHUP SIGTERM EXIT

# Execute zoom (or whatever)
do_work "$@"

# vim: ts=4 sw=4 noexpandtab
