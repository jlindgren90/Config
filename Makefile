CFLAGS = -std=c99 -Wall -O2 -g
CXXFLAGS = -std=c++17 -Wall -O2 -g
GUI_CFLAGS = $(shell pkg-config --cflags glib-2.0 Qt6Widgets) -fPIC
GUI_LIBS = $(shell pkg-config --libs glib-2.0 Qt6Widgets)
CP = cp --preserve=mode

all: tools/clutter tools/xlogout

tools/clutter: tools/clutter.cc
	g++ ${CXXFLAGS} -o tools/clutter tools/clutter.cc
	strip -s tools/clutter

tools/xlogout: tools/xlogout.cc
	g++ ${CXXFLAGS} ${GUI_CFLAGS} -o tools/xlogout tools/xlogout.cc ${GUI_LIBS}
	strip -s tools/xlogout

clean:
	rm -f tools/xlogout

install-user: all
	${CP} home/bash_profile ${HOME}/.bash_profile
	${CP} home/bashrc ${HOME}/.bashrc
	${CP} home/clang-format ${HOME}/.clang-format
	${CP} home/profile ${HOME}/.profile
	mkdir -p ${HOME}/bin
	rm -f ${HOME}/bin/clutter
	${CP} tools/clutter ${HOME}/bin/clutter
	rm -f ${HOME}/bin/xlogout
	${CP} tools/xlogout ${HOME}/bin/xlogout
	mkdir -p ${HOME}/.config
	${CP} -r home/config/* ${HOME}/.config/
	xdg-mime default thunar.desktop inode/directory
	# GTK/Wayland settings
	gsettings set org.gnome.desktop.interface cursor-theme default
	gsettings set org.gnome.desktop.interface font-antialiasing rgba
	gsettings set org.gnome.desktop.interface font-name "Sans 10"
	gsettings set org.gnome.desktop.interface gtk-theme Old-Style
	gsettings set org.gnome.desktop.interface icon-theme gnome
	gsettings set org.gnome.desktop.interface text-scaling-factor 1.0

install-system:
	find etc -type d -exec install -d ${DESTDIR}/\{\} \;
	find etc -type f -exec install -m644 \{\} ${DESTDIR}/\{\} \;
