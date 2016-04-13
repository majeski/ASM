OBJECTS = flow.o start.o step.o

main: main.c $(OBJECTS)
	gcc -o main main.c $(OBJECTS)

%.o: %.asm
	nasm -f elf64 $<

%: %.o
	ld $< -o $@ -lc --dynamic-linker=/lib64/ld-linux-x86-64.so.2

clean:
	rm -f $(OBJECTS) main
