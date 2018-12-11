#!/bin/sh

exec systemd-run --user --wait \
 -EDISPLAY="$DISPLAY" \
 -EPATH="$PATH" \
 ~/.xsession
