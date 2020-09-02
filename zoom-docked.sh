#!/bin/bash -e

# Allow for registering subprocesses to kill and files to remove on exit
declare -a PIDS RM
function killpids {
    [[ ${#PIDS[@]} -ne 0 ]] && kill "${PIDS[@]}"
    [[ ${#RM[@]} -ne 0 ]] && rm "${RM[@]}"
}
trap killpids SIGINT SIGHUP SIGTERM EXIT

# Args for Docker
declare -a ARGS
function addenv {
    ARGS+=('--env' "$1=$2")
}

# So Zoom can interact with X
addenv DISPLAY "$DISPLAY"

# entrypoint.sh uses these so the user IDs and such inside the container match those outside.
addenv USER_NAME "$(id -un)"
addenv USER_UID "$(id -u)"
addenv USER_GID "$(id -g)"
USER_HOME="$HOME"
addenv USER_HOME "$USER_HOME"

# Create these so they get the right permissions inside the container.
mkdir -p ~/.zoom-docked/.zoom
[[ -e ~/.zoom-docked/zoomus.conf ]] || touch ~/.zoom-docked/zoomus.conf

# If available, export xdg-open calls to the host via a fifo so clicking links in Zoom chat opens
# them in the host browser as expected.
if command -v xdg-open >/dev/null; then
    XDG_OPEN_FIFO=~/.zoom-docked/xdg-open-fifo.$$
    mkfifo -m 0600 "$XDG_OPEN_FIFO"
    RM+=($XDG_OPEN_FIFO)

    while true; do
        if read line <"$XDG_OPEN_FIFO"; then
            xdg-open "$line"
        fi
    done &
    PIDS+=($!)
    addenv XDG_OPEN_FIFO "$XDG_OPEN_FIFO"
fi

# If available, use xdg-dbus-proxy to proxy notification and screensaver-suppression DBus messages
# to the host's session bus.
if [[ ! -z "$DBUS_SESSION_BUS_ADDRESS" ]] && command -v xdg-dbus-proxy >/dev/null; then
    DBUS_PROXY_FILE=~/.zoom-docked/xdg-dbus-proxy.$$
    xdg-dbus-proxy "$DBUS_SESSION_BUS_ADDRESS" "$DBUS_PROXY_FILE" --filter \
        --talk=org.freedesktop.Notifications \
        --talk=org.freedesktop.ScreenSaver \
        --talk=org.freedesktop.PowerManagement.Inhibit &
    PIDS+=($!)
    RM+=($DBUS_PROXY_FILE)
    addenv DBUS_SESSION_BUS_ADDRESS "unix:path=$DBUS_PROXY_FILE"
fi

# Add video and audio devices
for dev in /dev/video*; do
    [[ -e "$dev" ]] && ARGS+=('--device' "$dev:$dev:rw")
done
ARGS+=('--device' "/dev/snd:/dev/snd:rw")

# Run Zoom. Use a unique container name and remove the container when done to avoid multiple
# instances running at once.
docker run --name zoom --rm \
    "${ARGS[@]}" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.zoom-docked:"$USER_HOME/.zoom-docked" \
    -v ~/.zoom-docked/.zoom:"$USER_HOME/.zoom" \
    anomiex/zoom-docked zoom "$@"
