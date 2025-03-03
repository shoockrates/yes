program.exe : main.c priority_queue.h priority_queue.o
	gcc -std=c99 -o program.exe main.c priority_queue.o

priority_queue.o : priority_queue.c priority_queue.h
	gcc -c -std=c99 priority_queue.c