pkgname=config
pkgver=0.1
pkgrel=1
arch=('x86_64')
install=config.install

depends=('acpid'
         'aeq'
         'alsa-utils'
         'cbatticon-qt'
         'compton'
         'ethtool'
         'fbida'
         'feh'
         'galculator'
         'git'
         'gmrun'
         'gnome-icon-theme'
         'gnome-keyring'
         'imagemagick'
         'iw'
         'keepassxc'
         'kio'
         'libxcursor'
         'maim'
         'network-manager-applet'
         'numlockx'
         'old-style-theme'
         'openbox'
         'polkit-gnome'
         'qmpanel'
         'qt5ct'
         'rsync'
         'srandrd'
         'ttf-liberation'
         'thunar'
         'tumbler'
         'volumeicon'
         'wmctrl'
         'xclip'
         'xcursor-vanilla-dmz'
         'xdotool'
         'xfce4-notifyd'
         'xfce4-terminal'
         'xorg-xdpyinfo'
         'xorg-xrandr'
         'xorg-xrdb'
         'xorg-xset'
         'xsettingsd')

package() {
    cd ..
    make DESTDIR="${pkgdir}" install-system
}
