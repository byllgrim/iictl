PREFIX = /usr/local
#FLORIST_SRC = /usr/share/ada/adainclude/florist
FLORIST_SRC = /usr/local/floristlib
LARGS = -largs -lflorist

#TODO elaborate makefile vs using gnatmake

all:
	gnatmake main.adb -o iictl -I${FLORIST_SRC} ${LARGS}

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f iictl ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/iictl

clean:
	rm -f iictl *.ali *.o
