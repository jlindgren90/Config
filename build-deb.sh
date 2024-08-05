mkdir -p config-0.1-1
cp -r DEBIAN config-0.1-1
make DESTDIR=config-0.1-1 install-system
dpkg-deb --build config-0.1-1
