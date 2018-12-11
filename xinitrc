#!/bin/sh

xrdb ~/.Xresources

exec systemd-run --user --wait \
 -EDISPLAY="$DISPLAY" \
 -EPATH="$PATH" \
 -EQT_QPA_PLATFORMTHEME=gtk2 \
 -ESAL_USE_VCLPLUGIN=gtk \
 xfce4-session
