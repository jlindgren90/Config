#!/bin/sh

systemctl --user import-environment

if test x"$XSESSION_STARTED" = x ; then
  exec systemd-run --user --wait -EXSESSION_STARTED=1 "$0"
fi

unset XSESSION_STARTED

export GTK_OVERLAY_SCROLLING=0
export QT_QPA_PLATFORMTHEME=gtk2
export SAL_USE_VCLPLUGIN=gtk

xrdb ~/.Xresources

setup-desktop
srandrd setup-desktop
xfsettingsd

compton &
xfce4-panel &
keepassxc &
nm-applet &
quick-settings &
volumeicon &
exec openbox
