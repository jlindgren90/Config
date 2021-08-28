#!/bin/sh

pacman -Scc

gtk-update-icon-cache /usr/share/icons/gnome
gtk-update-icon-cache /usr/share/icons/hicolor

echo / > inst.list
# /etc/ssl/certs is messy, shorten it
pacman -Qql | sed -e 's/\/$//' -e '/^\/etc\/ssl\/certs/d' | sort -u >> inst.list

find / -xdev | sort | sed -e '/^\/dev\//d' -e '/^\/proc\//d' -e '/^\/sys\//d' > files.list

diff inst.list files.list | shorten > files.diff
rm inst.list files.list
