CLANGLIB = ${HOME}/.local/lib/clang/8.0.0/lib/linux/ve
WELD = ${HOME}/weld/weld
WELDLIB = ${WELD}/weld_rt/cpp
CC = ncc
LIBS = -lweldrt-ve -lc++ -lc++abi -lunwind

all: tp dlopen

tp: main.c tp.c
	${CC} main.c tp.c -o $@ -L${CLANGLIB} -Wl,-rpath=${CLANGLIB} -L${WELDLIB} -Wl,-rpath=${WELDLIB} ${LIBS}

dlopen: dlopen.c
	${CC} dlopen.c -o $@
#	${CC} dlopen.c -o $@ -L${CLANGLIB} -Wl,-rpath=${CLANGLIB} -L${WELDLIB} -Wl,-rpath=${WELDLIB} ${LIBS}


tp.c:
	@echo ERROR: No tp.c is found.
	@echo please copy one of code-xxx.c to tp.c by hand.
	@exit 1

clean: FORCE
	rm -f tp dlopen

FORCE:

.phoines: FORCE all clean
