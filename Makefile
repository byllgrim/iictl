PREFIX = /usr/local

all: isup.o
	gnatmake iictl.adb -largs isup.o

isup.o:
	${CC} -c isup.c

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f iictl ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/iictl

clean:
	rm -f iictl *.ali *.o
