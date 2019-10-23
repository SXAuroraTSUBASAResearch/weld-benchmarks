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
WELD_NCC_CFLAGS="-w -fdiag-vector=2"

export WELD_COMPILATION_STATS WELD_RUN_STATS WELD_NCC_CFLAGS VE_NODE_NUMBER

EXE_B=bench

#    "params": {
#        "n": [10000000, 100000000],
#        "r": [1, 10],
#        "op": ["sqrt", "+"],
#        "i":[1, 0]

PARAM_N="10000000"
PARAM_R="1"
#PARAM_OP="sqrt"
PARAM_OP="+"
PARAM_I="1"

### Host Weld
if [ ${HOSTWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=-1
#  echo "python ${EXE_B} -n ${PARAM_N} -r ${PARAM_R} -op ${PARAM_OP} -i ${PARAM_I}"
         python ${EXE_B} -n ${PARAM_N} -r ${PARAM_R} -op ${PARAM_OP} -i ${PARAM_I} > runlog.hostweld 2>&1
fi

### VE-Weld
if [ ${VEWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=${EXEC_VE_NODE_NUMBER}
#  echo "python ${EXE_B} -n ${PARAM_N} -r ${PARAM_R} -op ${PARAM_OP} -i ${PARAM_I}"
         python ${EXE_B} -n ${PARAM_N} -r ${PARAM_R} -op ${PARAM_OP} -i ${PARAM_I} > runlog.veweld 2>&1
fi

if [ ${HOSTWELD_EXEC} -eq 1 -a ${VEWELD_EXEC} -eq 1 ];then
  grep 'result=' runlog.hostweld | grep Weld | cut -d= -f2 | cut -d')' -f1 > result.hostweld
  grep 'result=' runlog.veweld | grep Weld | cut -d= -f2 | cut -d')' -f1 > result.veweld
  diff result.hostweld result.veweld > /dev/null
  if [ $? -eq 0 ]; then
    echo "numpy_ops: OK"
  else
    echo "numpy_ops: NG: host-weld(" `cat result.hostweld` "),ve-weld(" `cat result.veweld` ")"
  fi
  rm result.hostweld result.veweld
fi
