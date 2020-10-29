#!/bin/bash

ZOOM_VER=$(curl -sA 'Mozilla/5.0 (X11; Linux x86_64)' https://zoom.us/download | grep -o '>Version [0-9.]\+<' | sed 's/[^0-9.]//g;')
if [[ -z "$ZOOM_VER" ]]; then
    echo "Failed to fetch Zoom version"
    exit 1
fi
echo "Zoom version:  $ZOOM_VER"

IMG_VER="Not installed"
if docker image inspect -f '{}' anomiex/zoom-docked > /dev/null 2>&1; then
    IMG_VER=$(docker run --rm anomiex/zoom-docked version)
fi
echo "Image version: $IMG_VER"

if [[ "$ZOOM_VER" != "$IMG_VER" ]]; then
    docker build --no-cache -t anomiex/zoom-docked .
else
    docker build -t anomiex/zoom-docked .
fi
