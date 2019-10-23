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
WELD_NCC_CFLAGS="-O3 -w -fdiag-vector=2"

NUM_ELEM="10000000"

export WELD_COMPILATION_STATS WELD_RUN_STATS WELD_NCC_CFLAGS VE_NODE_NUMBER

EXE_B=bench
rm -f libverun.so

### Numpy
if [ ${ORIG_EXEC} -eq 1 ]; then
#  echo "python bench -ie 0 -n ${NUM_ELEM} -numpy 1"
        python bench -ie 0 -n ${NUM_ELEM} -numpy 1 > runlog.numpy 2>&1
fi

### Host Weld
if [ ${HOSTWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=-1
#  echo "python ${EXE_B} -ie 0 -n ${NUM_ELEM} -weld 1"
        python ${EXE_B} -ie 0 -n ${NUM_ELEM} -weld 1 > runlog.hostweld 2>&1
fi

### VE-Weld
if [ ${VEWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=${EXEC_VE_NODE_NUMBER}
#  echo "python ${EXE_B} -ie 0 -n ${NUM_ELEM} -weld 1"
        python ${EXE_B} -ie 0 -n ${NUM_ELEM} -weld 1 > runlog.veweld 2>&1
fi

if [ ${HOSTWELD_EXEC} -eq 1 -a ${VEWELD_EXEC} -eq 1 ];then
  grep 'result=' runlog.hostweld | cut -d= -f2 | cut -d')' -f1 > result.hostweld
  grep 'result=' runlog.veweld | cut -d= -f2 | cut -d')' -f1 > result.veweld
  diff result.hostweld result.veweld > /dev/null
  if [ $? -eq 0 ]; then
    echo "blackscholes: OK"
  else
    echo "blackscholes: NG: host-weld(" `cat result.hostweld` "),ve-weld(" `cat result.veweld` ")"
  fi
  rm result.hostweld result.veweld
fi
  
