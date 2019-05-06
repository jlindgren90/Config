pkgname=config
pkgver=0.1
pkgrel=1
arch=('x86_64')

depends=('aeq'
         'compton'
         'ethtool'
         'feh'
         'galculator-gtk2'
         'gnome-icon-theme'
         'gtk2'
         'iw'
         'keepassxc'
         'lxqt-panel'
         'lxqt-policykit'
         'lxqt-powermanagement'
         'maim'
         'nemo'
         'network-manager-applet-gtk2'
         'numlockx'
         'old-style-theme'
         'openbox'
         'srandrd'
         'ttf-liberation'
         'volumeicon-gtk2'
         'wmctrl'
         'xclip'
         'xdotool'
         'xfce4-appfinder'
         'xfce4-terminal'
         'xorg-xrandr'
         'xorg-xrdb'
         'xorg-xset'
         'xsettingsd')

package() {
    cd ..
    make DESTDIR="${pkgdir}" install-system
}
