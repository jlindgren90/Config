CFLAGS = -std=c99 -Wall -O2 -g
CXXFLAGS = -std=c++17 -Wall -O2 -g
GUI_CFLAGS = $(shell pkg-config --cflags glib-2.0 Qt6Widgets) -fPIC
GUI_LIBS = $(shell pkg-config --libs glib-2.0 Qt6Widgets)
CP = cp --preserve=mode

SHELL := /bin/bash

ifeq (${DPI}, 128)
	export FONT_DPI=128
	export FONT_DPIx1024=131072
	export FONT_SCALE=1.3333
	export FONT_DEV_PTS=13
	export THEME=Old-Style-128dpi
else
	export FONT_DPI=96
	export FONT_DPIx1024=99328
	export FONT_SCALE=1
	export FONT_DEV_PTS=10
	export THEME=Old-Style
endif

gen:
	mkdir -p home/config/openbox
	envsubst < templates/environment > home/config/labwc/environment
	envsubst < templates/labwc-rc.xml > home/config/labwc/rc.xml
	envsubst < templates/openbox-rc.xml > home/config/openbox/rc.xml
	envsubst < templates/xprofile > home/config/xprofile
	envsubst < templates/xresources > home/config/xresources
	envsubst < templates/xsettings > home/config/xsettings

core-tools: tools/clutter

gui-tools: tools/quick-settings tools/xlogout

tools/clutter: tools/clutter.cc
	g++ ${CXXFLAGS} -o tools/clutter tools/clutter.cc
	strip -s tools/clutter

tools/quick-settings: tools/quick-settings.cc
	g++ ${CXXFLAGS} ${GUI_CFLAGS} -o tools/quick-settings tools/quick-settings.cc ${GUI_LIBS}
	strip -s tools/quick-settings

tools/xlogout: tools/xlogout.cc
	g++ ${CXXFLAGS} ${GUI_CFLAGS} -o tools/xlogout tools/xlogout.cc ${GUI_LIBS}
	strip -s tools/xlogout

clean:
	rm -f tools/quick-settings tools/shorten tools/xlogout

user-dirs:
	mkdir -p ${HOME}/bin
	mkdir -p ${HOME}/.config

user-core: core-tools user-dirs
	${CP} home/bash_profile ${HOME}/.bash_profile
	${CP} home/bashrc ${HOME}/.bashrc
	${CP} home/profile ${HOME}/.profile
	rm -f ${HOME}/bin/clutter
	${CP} tools/clutter ${HOME}/bin/clutter

user-dev: user-dirs
	${CP} home/bin/remerge ${HOME}/bin/
	${CP} home/clang-format ${HOME}/.clang-format
	${CP} -r home/config/{geany,QtProject} ${HOME}/.config/

user-scripts: user-dirs
	${CP} home/bin/* ${HOME}/bin/

user-gui-common: gen user-dirs
	${CP} -r home/config/{gtk-3.0,qt5ct,qt6ct} ${HOME}/.config/
	mkdir -p ${HOME}/.config/xfce4
	${CP} -r home/config/xfce4/terminal ${HOME}/.config/xfce4/
	${CP} home/config/xprofile ${HOME}/.config/
	xdg-mime default thunar.desktop inode/directory
	# Thunar settings
	xfconf-query -c thunar -n -t string -p /last-view -s ThunarCompactView
	xfconf-query -c thunar -n -t string -p /last-compact-view-zoom-level -s THUNAR_ZOOM_LEVEL_38_PERCENT
	xfconf-query -c thunar -n -t int -p /last-window-width -s 1200
	xfconf-query -c thunar -n -t int -p /last-window-height -s 800
	xfconf-query -c thunar -n -t int -p /last-separator-position -s 250

user-wm-common: gui-tools user-gui-common
	rm -f ${HOME}/bin/quick-settings
	${CP} tools/quick-settings ${HOME}/bin/quick-settings
	rm -f ${HOME}/bin/xlogout
	${CP} tools/xlogout ${HOME}/bin/xlogout
	${CP} home/bin/{disable,enable,query}-screensaver ${HOME}/bin/
	${CP} home/bin/run-once ${HOME}/bin/
	${CP} -r home/config/volumeicon ${HOME}/.config/
	${CP} home/config/{qmpanel.ini,quick-settings.ini} ${HOME}/.config/
	${CP} home/config/{xresources,xsettings} ${HOME}/.config/
	mkdir -p ${HOME}/.local/share
	${CP} -r home/local/share/applications ${HOME}/.local/share/

user-labwc: user-wm-common
	${CP} home/bin/wlscreenshot ${HOME}/bin/
	${CP} -r home/config/{kanshi,labwc,swayidle,swaylock} ${HOME}/.config/
	# GTK/Wayland settings
	gsettings set org.gnome.desktop.interface cursor-theme default
	gsettings set org.gnome.desktop.interface font-antialiasing rgba
	gsettings set org.gnome.desktop.interface font-name "Sans 10"
	gsettings set org.gnome.desktop.interface gtk-theme ${THEME}
	gsettings set org.gnome.desktop.interface icon-theme gnome
	gsettings set org.gnome.desktop.interface text-scaling-factor ${FONT_SCALE}
	# generate swaylock background
	echo "Enter ${USER}'s password to unlock this session:" \
	 >${HOME}/.config/swaylock/locktext.txt
	pango-view --background="#303030" --foreground="#f0f0f0" --font="Sans 10" \
	 --dpi=${FONT_DPI} -qo ${HOME}/.config/swaylock/locktext.png \
	 ${HOME}/.config/swaylock/locktext.txt

user-openbox: user-wm-common
	${CP} home/xsession ${HOME}/.xsession
	ln -sf .xsession ${HOME}/.xinitrc
	${CP} -r home/config/openbox ${HOME}/.config/
	${CP} home/config/picom.conf ${HOME}/.config/

user-xfce: user-gui-common
	${CP} -r home/config/xfce4 ${HOME}/.config/
	# XFCE settings
	xfconf-query -c xfwm4 -n -t string -p /general/button_layout -s "O|HMC"
	xfconf-query -c xfwm4 -n -t string -p /general/theme -s Default-4.4
	xfconf-query -c xfwm4 -n -t string -p /general/title_alignment -s left
	xfconf-query -c xfwm4 -n -t string -p /general/title_font -s "Sans Bold 10"
	xfconf-query -c xsettings -n -t string -p /Gtk/CursorThemeName -s default
	xfconf-query -c xsettings -n -t string -p /Gtk/FontName -s "Sans 10"
	xfconf-query -c xsettings -n -t string -p /Net/IconThemeName -s gnome
	xfconf-query -c xsettings -n -t string -p /Net/ThemeName -s ${THEME}
	xfconf-query -c xsettings -n -t string -p /Xft/HintStyle -s hintnone
	xfconf-query -c xsettings -n -t int -p /Xft/DPI -s ${FONT_DPI}

user-all: user-core user-dev user-scripts user-labwc user-openbox user-xfce

system:
	find etc -type d -exec install -d ${DESTDIR}/\{\} \;
	find etc -type f -exec install -m644 \{\} ${DESTDIR}/\{\} \;
