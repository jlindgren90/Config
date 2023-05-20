CFLAGS = -std=c99 -Wall -O2 -g
CXXFLAGS = -std=c++11 -Wall -O2 -g
GUI_CFLAGS = $(shell pkg-config --cflags glib-2.0 Qt5Widgets) -fPIC
GUI_LIBS = $(shell pkg-config --libs glib-2.0 Qt5Widgets)
CP = cp --preserve=mode

all: tools/quick-settings tools/shorten tools/xlogout

tools/quick-settings: tools/quick-settings.cc
	g++ ${CXXFLAGS} ${GUI_CFLAGS} -o tools/quick-settings tools/quick-settings.cc ${GUI_LIBS}
	strip -s tools/quick-settings

tools/shorten: tools/shorten.c
	gcc ${CFLAGS} -o tools/shorten tools/shorten.c
	strip -s tools/shorten

tools/xlogout: tools/xlogout.cc
	g++ ${CXXFLAGS} ${GUI_CFLAGS} -o tools/xlogout tools/xlogout.cc ${GUI_LIBS}
	strip -s tools/xlogout

clean:
	rm -f tools/quick-settings tools/shorten tools/xlogout

install-user: all
	${CP} home/bash_profile ${HOME}/.bash_profile
	${CP} home/bashrc ${HOME}/.bashrc
	${CP} home/profile ${HOME}/.profile
	${CP} home/xsession ${HOME}/.xsession
	${CP} -r home/bin ${HOME}/
	rm -f ${HOME}/bin/quick-settings
	${CP} tools/quick-settings ${HOME}/bin/quick-settings
	rm -f ${HOME}/bin/shorten
	${CP} tools/shorten ${HOME}/bin/shorten
	rm -f ${HOME}/bin/xlogout
	${CP} tools/xlogout ${HOME}/bin/xlogout
	mkdir -p ${HOME}/.config
	${CP} -r home/config/* ${HOME}/.config/
	mkdir -p ${HOME}/.local
	${CP} -r home/local/* ${HOME}/.local/
	xdg-mime default thunar.desktop inode/directory
	# GTK/Wayland settings
	gsettings set org.gnome.desktop.interface cursor-theme default
	gsettings set org.gnome.desktop.interface font-antialiasing rgba
	gsettings set org.gnome.desktop.interface font-name "Sans 10"
	gsettings set org.gnome.desktop.interface gtk-theme Old-Style-128dpi
	gsettings set org.gnome.desktop.interface icon-theme gnome
	gsettings set org.gnome.desktop.interface text-scaling-factor 1.33333
	# generate swaylock background
	echo "Session locked by ${USER} - enter password to unlock" \
	 >${HOME}/.config/swaylock/locktext.txt
	pango-view --background="#303030" --foreground="#f0f0f0" --font="Sans 10" \
	 --dpi=128 -qo ${HOME}/.config/swaylock/locktext.png \
	 ${HOME}/.config/swaylock/locktext.txt

install-system:
	find etc -type d -exec install -d ${DESTDIR}/\{\} \;
	find etc -type f -exec install -m644 \{\} ${DESTDIR}/\{\} \;
	find usr -type d -exec install -d ${DESTDIR}/\{\} \;
	find usr/bin -type f -exec install \{\} ${DESTDIR}/\{\} \;
	find usr/lib -type f -exec install -m644 \{\} ${DESTDIR}/\{\} \;
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
