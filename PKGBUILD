pkgname=config
pkgver=0.1
pkgrel=1
arch=('x86_64')

depends=('aeq'
         'compton'
         'cmst'
         'ethtool'
         'feh'
         'galculator-gtk2'
         'gmrun'
         'gnome-icon-theme'
         'gtk2'
         'iw'
         'keepassxc'
         'lxqt-policykit'
         'lxqt-powermanagement'
         'maim'
         'nemo'
         'numlockx'
         'old-style-theme'
         'openbox'
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
