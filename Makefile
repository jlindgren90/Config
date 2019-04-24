CC = gcc
CFLAGS = -std=c99 -Wall -O2 -g
GTK_CFLAGS = $(shell pkg-config --cflags gtk+-2.0)
GTK_LIBS = $(shell pkg-config --libs gtk+-2.0)
MKDIR = mkdir -p
RM = rm -f
CP = cp --preserve=mode
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
	${CP} profile ${HOME}/.profile
	${CP} xsession ${HOME}/.xsession
	${CP} -r home/bin ${HOME}/
	${RM} ${HOME}/bin/quick-settings
	${CP} quick-settings ${HOME}/bin/
	${RM} ${HOME}/bin/shorten
	${CP} shorten ${HOME}/bin/
	${MKDIR} ${HOME}/.config
	${CP} -r home/config/* ${HOME}/.config/
	${LN} xresources-128dpi ${HOME}/.config/xresources
	${LN} xsettings-128dpi ${HOME}/.config/xsettings
	${MKDIR} ${HOME}/.local
	${CP} -r home/local/* ${HOME}/.local/

install-system:
	${CP} -r etc ${DESTDIR}/
	${CP} -r usr ${DESTDIR}/
	${CHOWN} root:audio ${DESTDIR}/etc/asound.conf
	${CHMOD} 0664 ${DESTDIR}/etc/asound.conf
	${CHOWN} root:video ${DESTDIR}/etc/brightness-override
	${CHMOD} 0664 ${DESTDIR}/etc/brightness-override
