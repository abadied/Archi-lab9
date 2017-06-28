CC = gcc
FLAGS = -g -m32 -Wall

all : virusDetector

virusDetector : virusDetector.o
	$(CC) $(FLAGS) -o virusDetector virusDetector.o

virusDetector.o : virusDetector.c
	$(CC) $(FLAGS) -ansi -c -o virusDetector.o virusDetector.c

.PHONY : clean

clean :
	rm -f *.o virusDetector
