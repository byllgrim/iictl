.SUFFIXES:
.SUFFIXES: .adb .o

OBJ = $(SRC:.adb=.o)

all: $(PROG)

$(PROG): $(OBJ)
	gnatbind $(PROG)
	gnatlink $(PROG)

.adb.o:
	gnatgcc -c $<

clean:
	rm -rf $(PROG) *.o *.ali

.PHONY: all clean
