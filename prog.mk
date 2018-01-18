.SUFFIXES:
.SUFFIXES: .adb .o

OBJ = $(SRC:.adb=.o)
IPATH = /usr/share/ada/adainclude/florist
OPATH = /usr/lib/i386-linux-gnu/ada/adalib/florist
FLAGS = -Os -Wall -Wextra

all: $(PROG)

$(PROG): $(OBJ)
	gnatbind $(PROG) -aO$(OPATH) -static
	gnatlink $(PROG) -lflorist -static

.adb.o:
	gnatgcc -c $< -I$(IPATH) $(FLAGS)

clean:
	rm -rf $(PROG) *.o *.ali

.PHONY: all clean
