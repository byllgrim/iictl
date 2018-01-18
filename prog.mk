.SUFFIXES:
.SUFFIXES: .adb .ads .o

OBJ = $(SRC:=.o)
INC = -I.. -I/usr/share/ada/adainclude/florist
LIB = -aO/usr/lib/i386-linux-gnu/ada/adalib/florist
CFLAGS = -Os -Wall -Wextra

all: $(PROG)

$(PROG): $(OBJ)
	gnatbind $(PROG) $(LIB) -static
	gnatlink $(PROG) -lflorist -static

.ads.o:
	gnatgcc -c $< $(INC) $(CFLAGS)

.adb.o:
	gnatgcc -c $< $(INC) $(CFLAGS)

clean:
	rm -rf $(PROG) *.o *.ali

.PHONY: all clean
