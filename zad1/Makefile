OBJECTS = parse.o unparse.o suma.o roznica.o iloczyn.o iloraz.o negation.o isgreater.o multiply_s.o multiply_ten.o

main: main.c bcd.h $(OBJECTS)
	gcc -m32 -o main main.c $(OBJECTS)

%.o: %.asm
	nasm -f elf32 $<

%: %.o
	ld -m elf_i386 $< -o $@ -lc --dynamic-linker=/lib/ld-linux.so.2


clean:
	rm -f $(OBJECTS) main
