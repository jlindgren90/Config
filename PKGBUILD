pkgname=config
pkgver=0.1
pkgrel=1
arch=('x86_64')
install=config.install

depends=('aeq'
         'cbatticon-qt'
         'compton'
         'ethtool'
         'feh'
         'galculator-gtk2'
         'gmrun'
         'gnome-icon-theme'
         'gtk2'
         'iw'
         'keepassxc'
         'maim'
         'nemo'
         'network-manager-applet-gtk2'
         'numlockx'
         'old-style-theme'
         'openbox'
         'polkit-gnome'
         'qmpanel'
         'srandrd'
         'ttf-liberation'
         'volumeicon-gtk2'
         'wmctrl'
         'xclip'
         'xdotool'
         'xfce4-terminal'
         'xorg-xrandr'
         'xorg-xrdb'
         'xorg-xset'
         'xsettingsd')

package() {
    cd ..
    make DESTDIR="${pkgdir}" install-system
}
