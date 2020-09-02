#!/bin/bash

set -e

if [[ "$1" = "help" || -z "$1" ]]; then
		cat <<-'EOF' >&2
			Please use the `zoom-docked` wrapper script to run this container. It will set
			the environment correctly and mount the correct volumes.

			The wrapper script may be installed by passing `install` as the command to the
			container, with the installation directory mounted at `/target`. For example,

			  docker run -v /install/path:/target anomiex/zoom-docked install

		EOF
		exit 1
fi

if [[ "$1" = "install" ]]; then
	if [[ -d "/target" ]]; then
		install -m 0755 /var/scripts/zoom-docked /target/zoom-docked
		echo '`zoom-docked` wrapper has been installed!'
		exit 0
	else
		cat <<-'EOF' >&2
			To install the wrapper, mount the target directory at `/target`. For example,

			  docker run -v /install/path:/target anomiex/zoom-docked install

		EOF
		exit 1
	fi
fi

USER_NAME=${USER_NAME:-zoom}
USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}
USER_HOME=${USER_HOME:-"/home/$USER_NAME"}

if [[ ${RUNNING:-0} -eq 0 ]]; then
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
else
	# The container was already running. So just do some sanity checks.
	if [[ "$USER_UID" -ne "$(id -u "$USER_NAME")" ]]; then
		echo "Attempt to execute a command on a running container, but the UID for $USER_NAME does not match ($USER_UID != $(id -u "$USER_NAME"))!" >&2
		exit 1
	fi
	if [[ ! -d "$USER_HOME" ]]; then
		echo "Attempt to execute a command on a running container, but the home directory $USER_HOME doesn't exist!" >&2
		exit 1
	fi
fi

# Execute zoom (or whatever)
cd "$USER_HOME"
sudo -H --preserve-env=DISPLAY,XDG_OPEN_FIFO,DBUS_SESSION_BUS_ADDRESS -u "$USER_NAME" "$@"

# vim: ts=4 sw=4 noexpandtab
