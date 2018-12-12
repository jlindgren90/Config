CC = gcc
CFLAGS = -std=c99 -Wall -O2 -g
GTK_CFLAGS = $(shell pkg-config --cflags --libs gtk+-2.0)
MKDIR = mkdir -p
RM = rm -f
CP = cp --preserve=mode,timestamps
CHOWN = chown
CHMOD = chmod

all: quick-settings shorten

quick-settings: quick-settings.c
	${CC} ${CFLAGS} ${GTK_CFLAGS} -o quick-settings quick-settings.c

shorten: shorten.c
	${CC} ${CFLAGS} -o shorten shorten.c

clean:
	${RM} quick-settings shorten

install-user:
	${CP} bash_profile ${HOME}/.bash_profile
	${CP} quick-settings.ini ${HOME}/.quick-settings.ini
	${CP} profile ${HOME}/.profile
	${CP} Xresources ${HOME}/.Xresources
	${CP} xinitrc ${HOME}/.xinitrc
	${MKDIR} ${HOME}/bin
	${CP} check-backup ${HOME}/bin/
	${CP} clutter.sh ${HOME}/bin/
	${CP} quick-settings ${HOME}/bin/
	${CP} setup-desktop ${HOME}/bin/
	${CP} shorten ${HOME}/bin/
	${MKDIR} ${HOME}/.config/openbox
	${CP} openbox-rc.xml ${HOME}/.config/openbox/rc.xml

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
	${CP} adjust-brightness /usr/bin/adjust-brightness
