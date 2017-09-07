PREFIX = /usr/local
FLORIST_SRC = /usr/share/ada/adainclude/florist
FLORIST_LIB = /usr/lib/i386-linux-gnu/
LARGS = -largs-lflorist

#TODO elaborate makefile vs using gnatmake

all:
	#gnatmake -I${FLORIST_SRC} -a0${FLORIST_LIB} iictl.adb ${LARGS}
	gnatmake -aI/usr/share/ada/adainclude/florist -aO/usr/lib/ada/adalib/florist iictl.adb -largs -lflorist

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f iictl ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/iictl

clean:
	rm -f iictl *.ali *.o
