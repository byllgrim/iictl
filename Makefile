PREFIX = /usr/local
INC = -I/usr/share/ada/adainclude/florist -I/usr/local/floristlib
LARGS = -largs -lflorist

#TODO elaborate makefile vs using gnatmake

all:
	gnatmake main.adb -o iictl ${INC} ${LARGS}

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f iictl ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/iictl

clean:
	rm -rf iictl *.ali *.o
