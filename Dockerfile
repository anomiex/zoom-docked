# References: https://github.com/mdouchement/docker-zoom-us/blob/master/Dockerfile

FROM debian:buster-slim
MAINTAINER Brad Jorsch <anomie@users.sourceforge.net>

ENV DEBIAN_FRONTEND noninteractive

ARG ZOOM_URL=https://zoom.us/client/latest/zoom_amd64.deb

RUN \
  apt-get update && \
  apt-get -y install curl sudo \
    libxcb-keysyms1 libxcb-shape0 libxcb-randr0 libxcb-image0 libgl1-mesa-glx libegl1-mesa libpulse0 libxslt1.1 libxcb-xtest0 ibus && \
  \
  curl -L $ZOOM_URL -o /tmp/zoom_setup.deb && \
  dpkg -i /tmp/zoom_setup.deb && \
  rm /tmp/zoom_setup.deb && \
  \
  apt-get --purge --auto-remove -y remove curl && \
  rm -rf /var/lib/apt/lists/*

COPY zoom-docked /var/scripts/zoom-docked
COPY bin/docker-exec.sh bin/docker-run.sh /sbin/
COPY bin/xdg-open /usr/bin/xdg-open
RUN chmod 0755 /sbin/docker-exec.sh /sbin/docker-run.sh /usr/bin/xdg-open

ENTRYPOINT ["/sbin/docker-run.sh"]
CMD ["help"]
