pkgname=config
pkgver=0.1
pkgrel=1
arch=('x86_64')
install=config.install

depends=(
    # apps
    'galculator'
    'keepassxc'
    'thunar'
    'xfce4-terminal'

    # fonts
    'adobe-source-code-pro-fonts'
    'adobe-source-sans-fonts'
    'adobe-source-han-sans-otc-fonts'
    'adobe-source-serif-fonts'
    'noto-fonts-emoji'

    # keybindings
    'alsa-utils'
    'gmrun'
    'maim'
    'playerctl'
    'wmctrl'
    'xclip'

    # quick-settings
    'aeq'
    'xorg-xset'

    # theme
    'default-cursors'
    'gnome-icon-theme'
    'qt5ct'
    'qt6ct'
    'old-style-theme'
    'xcursor-vanilla-dmz'

    # xsession
    'cbatticon-qt'
    'network-manager-applet'
    'numlockx'
    'openbox'
    'picom'
    'polkit-gnome'
    'qmpanel'
    'srandrd'
    'volumeicon-qt'
    'xfce4-notifyd'
    'xorg-xrandr'
    'xorg-xrdb'
    'xsettingsd'

    # wayland
    'grim'
    'kanshi'
    'labwc'
    'slurp'
    'swaybg'
    'swayidle'
    'swaylock'
    'vulkan-driver'
    'wlopm'

    # acpi/udev
    'acpid'
    'ethtool'
    'iw'

    # ~/bin deps
    'aurutils'       # pkgreport.sh
    'colordiff'      # pkgreport.sh
    'fbida'          # reencode-jpeg
    'feh'            # setup-desktop
    'git'            # check-backup
    'imagemagick'    # reencode-jpeg
    'rsync'          # check-backup

    # optional deps
    'gnome-keyring'  # network-manager (wifi passwords)
    'tumbler'        # thunar (thumbnails)
)

package() {
    cd ..
    make DESTDIR="${pkgdir}" system
}
