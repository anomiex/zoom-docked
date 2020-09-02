# References: https://github.com/mdouchement/docker-zoom-us/blob/master/Dockerfile

FROM debian:buster-slim
MAINTAINER Brad Jorsch <anomie@users.sourceforge.net>

ENV DEBIAN_FRONTEND noninteractive

ARG ZOOM_URL=https://zoom.us/client/latest/zoom_amd64.deb

RUN \
# Dependencies for fetching, installing, and running zoom
  apt-get update && \
  apt-get -y install curl sudo \
    libxcb-keysyms1 libxcb-shape0 libxcb-randr0 libxcb-image0 libgl1-mesa-glx libegl1-mesa libpulse0 libxslt1.1 libxcb-xtest0 ibus && \
# Install Zoom
  curl -L $ZOOM_URL -o /tmp/zoom_setup.deb && \
  dpkg -i /tmp/zoom_setup.deb && \
  rm /tmp/zoom_setup.deb && \
# Cleanup
  apt-get --purge --auto-remove -y remove curl && \
  rm -rf /var/lib/apt/lists/*

COPY zoom-docked /var/scripts/zoom-docked
COPY bin/entrypoint.sh /sbin/entrypoint.sh
COPY bin/xdg-open /usr/bin/xdg-open
RUN chmod 0755 /sbin/entrypoint.sh /usr/bin/xdg-open

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["help"]
