#!/bin/sh

set -x

xhost +local:

exec docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /tmp:/home/luser/downloads captvty

