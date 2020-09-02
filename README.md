# Docker image for Zoom #

This is a `Dockerfile` to run [Zoom] for Linux inside a a [Docker] container.

## Background ##

Zoom became fairly well known in 2020, and not always for good reasons: it had a number of security
issues that made me wary of running it on my laptop. But the grid view is used often at my
workplace, and the web version doesn't support it, hence this docker file.

## Assumptions ##

This image currently makes a few assumptions:

* That exporting `$DISPLAY` is all that's needed for Zoom to display out of the container.
* That the video devices are at `/dev/video*`, and membership in group `video` is sufficient to
  access them.
* That the audio devices are at `/dev/snd`, and membership in group `audio` is sufficient to access
  them.

This container does not interface with the host's [PulseAudio], if any! If you want Zoom to
interface with PulseAudio, you might be better served by one of the projects mentioned in
[Credit](#Credit) below.

## Build ##

After cloning the repo, execute

```
docker build -t anomiex/zoom-docked .
```

## Usage ##

The included wrapper script `zoom-docked` should do the necessary work to execute Zoom. The image
itself may be used to install the wrapper script by invoking it as
```
docker run -v /install/path:/target anomiex/zoom-docked install
```

The directory `~/.zoom-docked/` is mounted inside the container at the same location, and may be
used for any necessary transfer of files to and from Zoom. Zoom's logs and such are located in
`~/.zoom-docked/.zoom`.

## Credit ##

The following projects were used as references when creating this:

* https://github.com/DmitrySandalov/docker-zoom
* https://github.com/mdouchement/docker-zoom-us

---
[Zoom]: http://www.zoom.us/
[Docker]: https://www.docker.com/
[PulseAudio]: https://www.freedesktop.org/wiki/Software/PulseAudio/
