all: myELF

myELF: myELF.o
	gcc -g -m32 -Wall -o myELF myELF.o

myELF.o: myELF.c
	gcc -g -m32 -Wall -Iinclude -c -o myELF.o myELF.c

skeleton: skeleton.o
	ld -m elf_i386 skeleton.o -o vir	

skeleton.o : skeleton.s
	nasm -f elf skeleton.s -o skeleton.o

.PHONY: clean

clean:
	rm -f *.o myELF