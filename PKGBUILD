pkgname=config
pkgver=0.1
pkgrel=1
arch=('x86_64')
install=config.install

depends=('acpid'
         'adobe-source-code-pro-fonts'
         'adobe-source-sans-fonts'
         'adobe-source-serif-fonts'
         'aeq'
         'alsa-utils'
         'cbatticon-qt'
         'colordiff'
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
         'tumbler'
         'volumeicon-qt'
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

build() {
    cd ..
    make
}

package() {
    cd ..
    make DESTDIR="${pkgdir}" install-system
}
