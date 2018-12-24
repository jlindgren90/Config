CC = gcc
CFLAGS = -std=c99 -Wall -O2 -g
GTK_CFLAGS = $(shell pkg-config --cflags gtk+-2.0)
GTK_LIBS = $(shell pkg-config --libs gtk+-2.0)
MKDIR = mkdir -p
RM = rm -f
CP = cp --preserve=mode,timestamps
LN = ln -sf
CHOWN = chown
CHMOD = chmod

all: quick-settings shorten

quick-settings: quick-settings.c
	${CC} ${CFLAGS} ${GTK_CFLAGS} -o quick-settings quick-settings.c ${GTK_LIBS}

shorten: shorten.c
	${CC} ${CFLAGS} -o shorten shorten.c

clean:
	${RM} quick-settings shorten

install-user:
	${CP} bash_profile ${HOME}/.bash_profile
	${CP} quick-settings.ini ${HOME}/.quick-settings.ini
	${CP} profile ${HOME}/.profile
	${CP} Xresources-96dpi ${HOME}/.Xresources-96dpi
	${CP} Xresources-128dpi ${HOME}/.Xresources-128dpi
	${LN} .Xresources-96dpi ${HOME}/.Xresources
	${CP} xinitrc ${HOME}/.xinitrc
	${CP} xsettingsd-96dpi ${HOME}/.xsettingsd-96dpi
	${CP} xsettingsd-128dpi ${HOME}/.xsettingsd-128dpi
	${LN} .xsettingsd-96dpi ${HOME}/.xsettingsd
	${MKDIR} ${HOME}/bin
	${CP} chdpi ${HOME}/bin/
	${CP} check-backup ${HOME}/bin/
	${CP} clutter.sh ${HOME}/bin/
	${RM} ${HOME}/bin/quick-settings
	${CP} quick-settings ${HOME}/bin/
	${CP} setup-desktop ${HOME}/bin/
	${RM} ${HOME}/bin/shorten
	${CP} shorten ${HOME}/bin/
	${MKDIR} ${HOME}/.config/geany/colorschemes
	${CP} kugel.conf ${HOME}/.config/geany/colorschemes/
	${MKDIR} ${HOME}/.config/menus
	${CP} programs.menu ${HOME}/.config/menus/
	${MKDIR} ${HOME}/.config/openbox
	${CP} openbox-rc.xml ${HOME}/.config/openbox/rc.xml
	${MKDIR} ${HOME}/.local/share/applications
	${CP} logout.desktop ${HOME}/.local/share/applications/
	${CP} run.desktop ${HOME}/.local/share/applications/

install-system:
	${CP} asound.conf.hdmi /etc
	${CP} asound.conf.laptop /etc
	${CP} asound.conf.laptop /etc/asound.conf
	${CHOWN} root:audio /etc/asound.conf
	${CHMOD} 0664 /etc/asound.conf
	${CP} brightness-override /etc/
	${CHOWN} root:video /etc/brightness-override
	${CHMOD} 0664 /etc/brightness-override
	${CP} lightdm-gtk-greeter.conf /etc/lightdm/
	${CP} backlight.rules /etc/udev/rules.d/
	${CP} powersave.rules /etc/udev/rules.d/
	${CP} compton.conf /etc/xdg/
	${CP} mouse.conf /etc/X11/xorg.conf.d/
	${CP} adjust-brightness /usr/bin/adjust-brightness
