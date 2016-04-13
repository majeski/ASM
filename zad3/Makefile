OBJECTS = flow.o start.o step.o

main: main.c $(OBJECTS)
	gcc -o main main.c $(OBJECTS)

flow.o: flow.c
	gcc -c flow.c

start.o: start.s
	as -o $@ $<

step.o: step.s
	as -o $@ $<

clean:
	rm -f $(OBJECTS) main
