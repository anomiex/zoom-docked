#!/bin/bash -e

# Allow for registering subprocesses to kill on exit
PIDS=
function killpids {
    [[ -z "$PIDS" ]] || kill $PIDS
}
trap killpids SIGINT SIGHUP SIGTERM EXIT

# Create these so they get the right permissions inside the container.
mkdir -p ~/.zoom-docked/.zoom
[[ -e ~/.zoom-docked/zoomus.conf ]] || touch ~/.zoom-docked/zoomus.conf

# Make a fifo and subprocess to export xdg-open calls to the host
if command -v xdg-open >/dev/null; then
    [[ -p ~/.zoom-docked/xdg-open-fifo ]] || mkfifo ~/.zoom-docked/xdg-open-fifo

    while true; do
        if read line <~/.zoom-docked/xdg-open-fifo; then
            xdg-open "$line"
        fi
    done &
    PIDS="$PIDS $!"
fi

# We need to pass this info into entrypoint.sh so the user IDs and such
# inside the container match those outside.
USER_NAME="$(id -un)"
USER_UID="$(id -u)"
USER_GID="$(id -g)"
USER_HOME="$HOME"

docker run --name zoom --rm \
    -e DISPLAY="$DISPLAY" \
    -e USER_NAME="$USER_NAME" \
    -e USER_UID="$USER_UID" \
    -e USER_GID="$USER_GID" \
    -e USER_HOME="$USER_HOME" \
    --device /dev/video0:/dev/video0 \
    --device /dev/snd \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.zoom-docked:"$USER_HOME/.zoom-docked" \
    -v ~/.zoom-docked/zoomus.conf:"$USER_HOME/.config/zoomus.conf" \
    -v ~/.zoom-docked/.zoom:"$USER_HOME/.zoom" \
    anomiex/zoom-docked zoom "$@"
