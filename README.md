# Docker image for Zoom #

This is a `Dockerfile` to run [Zoom] for Linux inside a [Docker] container.

## Background ##

Zoom became fairly well known in 2020, and not always for good reasons: it had a number of security
issues that made me wary of running it on my laptop. But the grid view is used often at my
workplace, and the web version doesn't support it, hence this docker file.

## Assumptions ##

This image currently makes a few assumptions:

* That exporting `$DISPLAY` and `/tmp/.X11-unix` is all that's needed for Zoom to display out of the
  container.
* That the video devices are at `/dev/video*`, and membership in group `video` is sufficient to
  access them.
* That the audio devices are at `/dev/snd`, and membership in group `audio` is sufficient to access
  them.

This container does not interface with the host's [PulseAudio], if any! Pull requests to add PA
support would also be welcome as long as they don't break non-PA usage.

## Build ##

After cloning the repo, execute

```
docker build -t anomiex/zoom-docked .
```

## Usage ##

The included wrapper script `zoom-docked` should do the necessary work to execute Zoom. The image
itself may be used to install the wrapper script by invoking it as something like
```
docker run -v /install/path:/target anomiex/zoom-docked install
```

If you want links clicked in Zoom—including those for SSO—to work, the `xdg-open` command from
[xdg-utils] must be installed on the host (and properly configured, if necessary). The container
will then exfiltrate clicked links to open them in the host browser.

You may also want to install [xdg-dbus-proxy] to allow Zoom to inhibit screensavers and powersave
shutdowns during meetings.

The directory `~/.zoom-docked/` is mounted inside the container at the same location, and may be
used for any necessary transfer of files to and from Zoom. Zoom's logs and such are located in
`~/.zoom-docked/.zoom`.

## Notes ##

If you don't like Zoom minimising itself to the taskbar when you close the window instead of
actually exiting, look for `forceEnableTrayIcon` in `~/.zoom-docked/zoomus.conf` and change it to
`false`. And then if logged in look in the settings for a "When closed, quit the application
directly" option. This works with Zoom 5.2.454870.0831, at least.

If you need to pass extra arguments to Docker, set the environment variable
`ZOOM_EXTRA_DOCKER_ARGS`. You can also set `ZOOM_COMMAND` to execute something other than Zoom. For
example, you might poke around the container in a shell with
```
ZOOM_EXTRA_DOCKER_ARGS=-it ZOOM_COMMAND=bash zoom-docked
```

## Credit ##

The following projects were used as references when creating this:

* https://github.com/DmitrySandalov/docker-zoom
* https://github.com/mdouchement/docker-zoom-us

---
[Zoom]: http://www.zoom.us/
[Docker]: https://www.docker.com/
[PulseAudio]: https://www.freedesktop.org/wiki/Software/PulseAudio/
[xdg-utils]: https://www.freedesktop.org/wiki/Software/xdg-utils/
[xdg-dbus-proxy]: https://github.com/flatpak/xdg-dbus-proxy
