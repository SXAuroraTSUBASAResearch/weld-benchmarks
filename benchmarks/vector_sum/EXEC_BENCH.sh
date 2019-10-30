#!/bin/sh

if [ $# -ne 4 ]; then
  echo "Error: Need 4 args"
  exit 1
fi

EXEC_VE_NODE_NUMBER=$1
ORIG_EXEC=$2
HOSTWELD_EXEC=$3
VEWELD_EXEC=$4

#WELD_COMPILATION_STATS=true
WELD_RUN_STATS=true

WELD_NCC_CFLAGS="-fdiag-vector=2 -O3"
#VEWELD_CFLAGS="-veweld-no-conv-bool-to-int"

LD_LIBRARY_PATH=${WELD_HOME}/target/release

export WELD_RUN_STATS VE_NODE_NUMBER WELD_NCC_CFLAGS VEWELD_CFLAGS LD_LIBRARY_PATH

ARG_N="400000000"  # out of memory

make > makelog 2>&1
if [ $? -ne 0 ]; then
  echo "vector: make error"
  exit 1
fi

### Host Weld
if [ ${HOSTWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=-1
  ./bench -n ${ARG_N} > runlog.hostweld 2>&1
fi

### VE-Weld
if [ ${VEWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=${EXEC_VE_NODE_NUMBER}
#  RUST_BACKTRACE=1
#  export RUST_BACKTRACE
  ./bench -n ${ARG_N} > runlog.veweld 2>&1
fi

if [ ${HOSTWELD_EXEC} -eq 1 -a ${VEWELD_EXEC} -eq 1 ];then
  grep 'result=' runlog.hostweld | grep Weld | cut -d= -f2 | cut -d')' -f1 > result.hostweld
  grep 'result=' runlog.veweld | grep Weld | cut -d= -f2 | cut -d')' -f1 > result.veweld
  diff result.hostweld result.veweld > /dev/null
  if [ $? -eq 0 ]; then
    echo "tpch_q6: OK: host-weld(" `grep 'call run' runlog.hostweld` "),ve-weld(" `grep 'call run' runlog.veweld` ")"
  else
    echo "tpch_q6: NG: host-weld(" `cat result.hostweld` "),ve-weld(" `cat result.veweld` ")"
  fi
  rm result.hostweld result.veweld
fi
