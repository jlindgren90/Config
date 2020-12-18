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

all: tools/quick-settings tools/shorten

tools/quick-settings: tools/quick-settings.c
	${CC} ${CFLAGS} ${GTK_CFLAGS} -o tools/quick-settings tools/quick-settings.c ${GTK_LIBS}

tools/shorten: tools/shorten.c
	${CC} ${CFLAGS} -o tools/shorten tools/shorten.c

clean:
	${RM} tools/quick-settings tools/shorten

install-user:
	${CP} home/bash_profile ${HOME}/.bash_profile
	${CP} home/profile ${HOME}/.profile
	${CP} home/xsession ${HOME}/.xsession
	${CP} -r home/bin ${HOME}/
	${RM} ${HOME}/bin/quick-settings
	${CP} tools/quick-settings ${HOME}/bin/
	${RM} ${HOME}/bin/shorten
	${CP} tools/shorten ${HOME}/bin/
	${MKDIR} ${HOME}/.config
	${CP} -r home/config/* ${HOME}/.config/
	${MKDIR} ${HOME}/.local
	${CP} -r home/local/* ${HOME}/.local/
	chdpi 128

install-system:
	find etc -type d -exec install -d ${DESTDIR}/\{\} \;
	find etc -type f -exec install -m644 \{\} ${DESTDIR}/\{\} \;
	find usr -type d -exec install -d ${DESTDIR}/\{\} \;
	find usr/bin -type f -exec install \{\} ${DESTDIR}/\{\} \;
	find usr/lib -type f -exec install -m644 \{\} ${DESTDIR}/\{\} \;
	install -d -m750 ${DESTDIR}/root
	install -m640 root/Xdefaults ${DESTDIR}/root/.Xdefaults
	install -m640 root/gtkrc-2.0 ${DESTDIR}/root/.gtkrc-2.0
	chown root:audio ${DESTDIR}/etc/asound.conf
	chmod 0664 ${DESTDIR}/etc/asound.conf
	chown root:video ${DESTDIR}/etc/brightness-override
	chmod 0664 ${DESTDIR}/etc/brightness-override
