#!/bin/sh
case "$3" in
    plug)
        aeq disable > /dev/null
        amixer sset Speaker mute
        amixer sset Headphone unmute
        ;;
    unplug)
        aeq enable > /dev/null
        amixer sset Headphone mute
        amixer sset Speaker unmute
        ;;
esac
