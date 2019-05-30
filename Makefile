CC = gcc
CFLAGS = -O3 -Wall
CFLAGS += -D_FILE_OFFSET_BITS=64
CFLAGS += -D_LARGEFILE_SOURCE
CFLAGS += -fno-exceptions
CFLAGS += -funroll-loops

default: all

all: count reduce test_int

count: count.c
	$(CC) $(CFLAGS) count.c -o count

reduce: reduce.c
	$(CC) $(CFLAGS) reduce.c -o reduce

test_int: test/test_int.c
	$(CC) $(CFLAGS) test/test_int.c -o test/test_int

clean:
	rm count reduce test/test_int
