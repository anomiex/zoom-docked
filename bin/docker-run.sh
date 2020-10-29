#!/bin/bash

set -e

. /usr/share/zoom-docked/docker-shared.sh

# Docker will have created /home/$USER_NAME as root to mount
# the volumes. Fix that. And create ~/.config too.
mkdir -p "$USER_HOME/.config/"
chown "$USER_UID:$USER_GID" --from=0:0 -R "$USER_HOME"

# Create the user and group.
addgroup --quiet --gid "$USER_GID" "$USER_NAME"
adduser --quiet --disabled-login --uid "$USER_UID" --gid "$USER_GID" \
	--no-create-home --home="$USER_HOME" \
	--gecos 'Zoom' "$USER_NAME"

# Add to video and audio groups, for access to video and audio devices.
# The weird stuff is to work around https://bugs.debian.org/558260, adduser always prints a message
# to stderr when adding a user to a group but we only care on an actual error.
TMP=$(adduser --quiet "$USER_NAME" video 2>&1) || { echo $TMP; exit 1; }
TMP=$(adduser --quiet "$USER_NAME" audio 2>&1) || { echo $TMP; exit 1; }

# Copy zoomus.conf into position. Zoom tries to update it by renaming, which doesn't work for a file bind mount.
[[ -e "$USER_HOME/.zoom-docked/zoomus.conf" ]] && cp -a "$USER_HOME/.zoom-docked/zoomus.conf" "$USER_HOME/.config/zoomus.conf"

# Copy zoomus.conf back on exit
function uncopyconf {
	[[ -e "$USER_HOME/.config/zoomus.conf" ]] && cp -a "$USER_HOME/.config/zoomus.conf" "$USER_HOME/.zoom-docked/zoomus.conf"
}
trap uncopyconf SIGINT SIGHUP SIGTERM EXIT

# Execute zoom (or whatever)
cd "$USER_HOME"
sudo -H --preserve-env=DISPLAY,XDG_OPEN_FIFO,DBUS_SESSION_BUS_ADDRESS -u "$USER_NAME" "$@"

# vim: ts=4 sw=4 noexpandtab
