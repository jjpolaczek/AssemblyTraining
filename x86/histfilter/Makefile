CC=g++
CFLAGS= -g3 -O0 -fPIC
#INCLUDES=-I./SFML/include
LIBS=-lsfml-graphics -lsfml-window -lsfml-system

ASM=nasm
AFLAGS=-f elf64 

all:result

main.o: main.c
	$(CC) $(CFLAGS)  $(LIBS) -c main.c
func.o: func.asm
	$(ASM) $(AFLAGS) func.asm
result: main.o func.o
	$(CC) $(CFLAGS) main.o func.o $(LIBS) -o result
clean:
	rm *.o
	rm result
