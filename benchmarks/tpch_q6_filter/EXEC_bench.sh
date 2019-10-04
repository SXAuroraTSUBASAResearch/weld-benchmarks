#!/bin/sh

WELD_RUN_STATS="true"

VE_NODE_NUMBER=${1:-"-1"}
shift
if [ $# -gt 0 ]; then
  ADDOPT="$*"
  echo $ADDOPT
  export ADDOPT
fi

WELD_NCC_CFLAGS="-fdiag-vector=2 -O3"
#VEWELD_CFLAGS="-veweld-no-conv-bool-to-int"
#VEWELD_CFLAGS="-veweld-tentative-no-write-back"

LD_LIBRARY_PATH=${WELD_HOME}/target/release

export WELD_RUN_STATS VE_NODE_NUMBER WELD_NCC_CFLAGS VEWELD_CFLAGS LD_LIBRARY_PATH

ARG_P="1.0"
ARG_N="20000000"
#ARG_N="200000000"
#ARG_N="2000000000"

make

./filter -p ${ARG_P} -n ${ARG_N}

