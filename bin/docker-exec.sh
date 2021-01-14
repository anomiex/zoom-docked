#!/bin/bash

set -eo pipefail

. /usr/share/zoom-docked/docker-shared.sh

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
do_work "$@"

# vim: ts=4 sw=4 noexpandtab
