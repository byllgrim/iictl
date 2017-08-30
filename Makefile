PREFIX = /usr/local

all:
	gnatmake iictl.adb

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f iictl ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/iictl
