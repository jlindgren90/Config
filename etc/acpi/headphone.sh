#!/bin/sh
case "$3" in
    plug)
        aeq disable >> /dev/null
        amixer set Speaker mute >> /dev/null
        ;;
    unplug)
        aeq enable >> /dev/null
        amixer set Speaker unmute >> /dev/null
        ;;
esac
