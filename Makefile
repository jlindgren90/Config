CC = gcc
CFLAGS = -std=c99 -Wall -O2 -g
GTK_CFLAGS = $(shell pkg-config --cflags --libs gtk+-2.0)
MKDIR = mkdir -p
RM = rm -f
CP = cp --preserve=mode,timestamps

all: quick-settings shorten

quick-settings: quick-settings.c
	${CC} ${CFLAGS} ${GTK_CFLAGS} -o quick-settings quick-settings.c

shorten: shorten.c
	${CC} ${CFLAGS} -o shorten shorten.c

clean:
	${RM} quick-settings shorten

install-user:
	${RM} ${HOME}/.bash_profile
	${CP} bash_profile ${HOME}/.bash_profile
	${RM} ${HOME}/.quick-settings.ini
	${CP} quick-settings.ini ${HOME}/.quick-settings.ini
	${RM} ${HOME}/.profile
	${CP} profile ${HOME}/.profile
	${RM} ${HOME}/.Xresources
	${CP} Xresources ${HOME}/.Xresources
	${RM} ${HOME}/.xinitrc
	${CP} xinitrc ${HOME}/.xinitrc
	${MKDIR} ${HOME}/bin
	${RM} ${HOME}/bin/check-backup
	${CP} check-backup ${HOME}/bin/
	${RM} ${HOME}/bin/clutter.sh
	${CP} clutter.sh ${HOME}/bin/
	${RM} ${HOME}/bin/quick-settings
	${CP} quick-settings ${HOME}/bin/
	${RM} ${HOME}/bin/setup-desktop
	${CP} setup-desktop ${HOME}/bin/
	${RM} ${HOME}/bin/shorten
	${CP} shorten ${HOME}/bin/
	${MKDIR} ${HOME}/.config/openbox
	${RM} ${HOME}/.config/openbox/rc.xml
	${CP} openbox-rc.xml ${HOME}/.config/openbox/rc.xml
