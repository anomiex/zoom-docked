#!/bin/bash

export USER_NAME=${USER_NAME:-zoom}
export USER_UID=${USER_UID:-1000}
export USER_GID=${USER_GID:-1000}
export USER_HOME=${USER_HOME:-"/home/$USER_NAME"}

if [[ "$1" = "help" || -z "$1" ]]; then
	cat <<-'EOF' >&2
		Please use the `zoom-docked` wrapper script to run this container. It will set
		the environment correctly and mount the correct volumes.

		The wrapper script may be installed by passing `install` as the command to the
		container, with the installation directory mounted at `/target`. For example,

		  docker run --rm -v /install/path:/target anomiex/zoom-docked install

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

			  docker run --rm -v /install/path:/target anomiex/zoom-docked install

		EOF
		exit 1
	fi
fi

if [[ "$1" = "version" ]]; then
	cat /etc/zoom-version
	exit 0
fi

# vim: ts=4 sw=4 noexpandtab
