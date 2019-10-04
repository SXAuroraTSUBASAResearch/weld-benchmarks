UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    CC=clang++
endif

ifeq ($(UNAME_S),Linux)
    CC=gcc -fopenmp
endif

CPPFLAGS=-O3 -march=native -std=c++11 -I$(WELD_HOME)/weld-capi $(ADDOPT)
LDFLAGS=-L$(WELD_HOME)/target/release
LIBS=-lweld

.PHONY: all clean

all:
	${CC} ${LDFLAGS} tpch_q6_filter.cpp ${CPPFLAGS} -o filter ${LIBS}

clean:
	rm -f filter libverun.so
