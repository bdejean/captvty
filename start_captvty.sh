#!/bin/sh

set -x

xhost +local:

[ -d /tmp/captvty ] || mkdir /tmp/captvty
chmod 2777 /tmp/captvty

exec docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /tmp/captvty:/home/luser/downloads captvty

