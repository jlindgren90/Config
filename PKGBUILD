pkgname=config
pkgver=0.1
pkgrel=1
arch=('x86_64')
install=config.install

depends=('acpid'
         'adobe-source-code-pro-fonts'
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
         'thunar'
         'ttf-ms-fonts'
         'tumbler'
         'urxvt-perls'
         'urxvt-tabbedex'
         'volumeicon'
         'wmctrl'
         'xclip'
         'xcursor-vanilla-dmz'
         'xdotool'
         'xfce4-notifyd'
         'xorg-xdpyinfo'
         'xorg-xrandr'
         'xorg-xrdb'
         'xorg-xset'
         'xseticon'
         'xsettingsd')

build() {
    cd ..
    make
}

package() {
    cd ..
    make DESTDIR="${pkgdir}" install-system
}
