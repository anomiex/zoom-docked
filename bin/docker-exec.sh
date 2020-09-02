#!/bin/bash

set -e

USER_NAME=${USER_NAME:-zoom}
USER_UID=${USER_UID:-1000}
USER_HOME=${USER_HOME:-"/home/$USER_NAME"}

# The container was already running. So just do some sanity checks.
EXISTING_USER_UID=$(id -u "$USER_NAME" 2>/dev/null)
if [[ -z "$EXISTING_USER_UID" ]]; then
	echo "Attempt to execute a command on a running container, but the user $USER_NAME does not exist!" >&2
	exit 1
fi
if [[ "$USER_UID" -ne "$EXISTING_USER_UID" ]]; then
	echo "Attempt to execute a command on a running container, but the UID for $USER_NAME does not match ($USER_UID != $EXISTING_USER_UID)!" >&2
	exit 1
fi
if [[ ! -d "$USER_HOME" ]]; then
	echo "Attempt to execute a command on a running container, but the home directory $USER_HOME doesn't exist!" >&2
	exit 1
fi

# Execute zoom (or whatever)
cd "$USER_HOME"
sudo -H --preserve-env=DISPLAY,XDG_OPEN_FIFO,DBUS_SESSION_BUS_ADDRESS -u "$USER_NAME" "$@"

# vim: ts=4 sw=4 noexpandtab
