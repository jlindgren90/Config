#!/bin/sh

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
openbox
