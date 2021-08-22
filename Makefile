CFLAGS = -std=c99 -Wall -O2 -g
CXXFLAGS = -std=c++11 -Wall -O2 -g
GUI_CFLAGS = $(shell pkg-config --cflags glib-2.0 Qt5Widgets) -fPIC
GUI_LIBS = $(shell pkg-config --libs glib-2.0 Qt5Widgets)
CP = cp --preserve=mode

all: tools/quick-settings tools/shorten

tools/quick-settings: tools/quick-settings.cc
	g++ ${CXXFLAGS} ${GUI_CFLAGS} -o tools/quick-settings tools/quick-settings.cc ${GUI_LIBS}

tools/shorten: tools/shorten.c
	gcc ${CFLAGS} -o tools/shorten tools/shorten.c

clean:
	rm -f tools/quick-settings tools/shorten

install-user:
	${CP} home/bash_profile ${HOME}/.bash_profile
	${CP} home/bashrc ${HOME}/.bashrc
	${CP} home/profile ${HOME}/.profile
	${CP} home/xsession ${HOME}/.xsession
	${CP} -r home/bin ${HOME}/
	mkdir -p ${HOME}/.config
	${CP} -r home/config/* ${HOME}/.config/
	mkdir -p ${HOME}/.local
	${CP} -r home/local/* ${HOME}/.local/
	${HOME}/bin/chdpi 128
	xdg-mime default thunar.desktop inode/directory

install-system:
	find etc -type d -exec install -d ${DESTDIR}/\{\} \;
	find etc -type f -exec install -m644 \{\} ${DESTDIR}/\{\} \;
	find usr -type d -exec install -d ${DESTDIR}/\{\} \;
	find usr/bin -type f -exec install \{\} ${DESTDIR}/\{\} \;
	find usr/lib -type f -exec install -m644 \{\} ${DESTDIR}/\{\} \;
	install tools/quick-settings ${DESTDIR}/usr/bin/quick-settings
	install tools/shorten ${DESTDIR}/usr/bin/shorten
	install -d -m750 ${DESTDIR}/root
	install -m640 root/Xdefaults ${DESTDIR}/root/.Xdefaults
	install -m640 root/gtkrc-2.0 ${DESTDIR}/root/.gtkrc-2.0
	chmod 0755 ${DESTDIR}/etc/acpi/headphone.sh
	chown root:audio ${DESTDIR}/etc/asound.conf
	chmod 0664 ${DESTDIR}/etc/asound.conf
	chown root:video ${DESTDIR}/etc/brightness-override
	chmod 0664 ${DESTDIR}/etc/brightness-override
