#!/bin/sh

# clean caches
rm /var/lib/systemd/coredump/core.*
journalctl --rotate --vacuum-time=1d
pacman -Scc

gtk-update-icon-cache /usr/share/icons/gnome
gtk-update-icon-cache /usr/share/icons/hicolor
