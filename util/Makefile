
TARGET=build_bootable_floppy
OBJECTS=build_bootable_floppy.o floppy.o

$(TARGET) : $(OBJECTS)
	gcc -o $@ $^

build_bootable_floppy.o : build_bootable_floppy.c bootloader.h
	gcc -c -o build_bootable_floppy.o build_bootable_floppy.c

%.o : %.c
	gcc -c -o $@ $^


clean:
	rm $(TARGETS) $(OBJECTS) 2>/dev/null
