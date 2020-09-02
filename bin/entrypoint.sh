#!/bin/bash

set -e

USER_NAME=${USER_NAME:-zoom}
USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}
USER_HOME=${USER_HOME:-"/home/$USER_NAME"}

echo "=== Setting up user ==="

# Docker will have created /home/$USER_NAME as root to mount
# the volumes. Fix that. And create ~/.config too.
mkdir -p "$USER_HOME/.config/"
chown "$USER_UID:$USER_GID" --from=0:0 -R "$USER_HOME"

# Create the user and group.
groupadd -f -g "$USER_GID" "$USER_NAME"
adduser --disabled-login --uid "$USER_UID" --gid "$USER_GID" \
    --no-create-home --home="$USER_HOME" \
    --gecos 'Zoom' "$USER_NAME"

# Add to video and audio groups, for access to video and audio devices.
adduser "$USER_NAME" video
adduser "$USER_NAME" audio

echo "=== Executing $1 ==="

# Copy zoomus.conf into position. Zoom tries to update it by renaming, which doesn't work for a file bind mount.
cp -a "$USER_HOME/.zoom-docked/zoomus.conf" "$USER_HOME/.config/zoomus.conf"

# Execute zoom (or whatever)
cd "$USER_HOME"
sudo -H --preserve-env=DISPLAY,XDG_OPEN_FIFO,DBUS_SESSION_BUS_ADDRESS -u "$USER_NAME" "$@"

# Copy zoomus.conf back
cp -a "$USER_HOME/.config/zoomus.conf" "$USER_HOME/.zoom-docked/zoomus.conf"
