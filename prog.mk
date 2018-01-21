.SUFFIXES:
.SUFFIXES: .adb .ads .o

OBJ = $(SRC:=.o)
ALI = $(SRC:=.ali)
INC = -I.. -I/usr/share/ada/adainclude/florist
LIB = -aO/usr/lib/`arch`-linux-gnu/ada/adalib/florist
CFLAGS = -Os -Wall -Wextra

all: $(PROG)

$(PROG): $(OBJ)
	gnatbind $(PROG) $(LIB) -static
	gnatlink $(PROG) -lflorist -static

.ads.o:
	gnatgcc -o $@ -c $< $(INC) $(CFLAGS)

.adb.o:
	gnatgcc -o $@ -c $< $(INC) $(CFLAGS)

clean:
	rm -rf $(PROG) $(OBJ) $(ALI)

.PHONY: all clean
