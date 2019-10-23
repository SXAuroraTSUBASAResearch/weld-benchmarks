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

ARG_P="1.0"
ARG_N="20000000"

make > makelog 2>&1
if [ $? -ne 0 ]; then
  echo "tpch_q6_filter: make error"
fi

### Host Weld
if [ ${HOSTWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=-1
  ./filter -p ${ARG_P} -n ${ARG_N}  > runlog.hostweld 2>&1
fi

### VE-Weld
if [ ${VEWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=${EXEC_VE_NODE_NUMBER}
  ./filter -p ${ARG_P} -n ${ARG_N}  > runlog.veweld 2>&1
fi

if [ ${HOSTWELD_EXEC} -eq 1 -a ${VEWELD_EXEC} -eq 1 ];then
  grep 'result=' runlog.hostweld | grep Weld | cut -d= -f2 | cut -d')' -f1 > result.hostweld
  grep 'result=' runlog.veweld | grep Weld | cut -d= -f2 | cut -d')' -f1 > result.veweld
  diff result.hostweld result.veweld > /dev/null
  if [ $? -eq 0 ]; then
    echo "tpch_q6_filter: OK"
  else
    echo "tpch_q6_filter: NG: host-weld(" `cat result.hostweld` "),ve-weld(" `cat result.veweld` ")"
  fi
  rm result.hostweld result.veweld
fi

