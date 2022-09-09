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
	xdg-mime default thunar.desktop inode/directory
	gsettings set org.gnome.desktop.interface cursor-theme default
	gsettings set org.gnome.desktop.interface font-antialiasing rgba
	gsettings set org.gnome.desktop.interface font-name "Sans 10"
	gsettings set org.gnome.desktop.interface gtk-theme Old-Style-128dpi
	gsettings set org.gnome.desktop.interface icon-theme gnome
	gsettings set org.gnome.desktop.interface text-scaling-factor 1.33333

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
	touch ${DESTDIR}/etc/brightness-override
	chown root:video ${DESTDIR}/etc/brightness-override
	chmod 0664 ${DESTDIR}/etc/brightness-override
	touch ${DESTDIR}/etc/dual-displays
	chown root:video ${DESTDIR}/etc/dual-displays
	chmod 0664 ${DESTDIR}/etc/dual-displays
