#!/bin/sh
case "$3" in
    plug)
        aeq disable > /dev/null
        ;;
    unplug)
        aeq enable > /dev/null
        ;;
esac
