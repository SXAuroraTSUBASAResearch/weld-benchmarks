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
VEWELD_CFLAGS="-veweld-infer-filter-size"

export WELD_COMPILATION_STATS WELD_RUN_STATS WELD_NCC_CFLAGS VEWELD_CFLAGS VE_NODE_NUMBER

EXE_B=nbody.py
ARG_N="-n 10000"
ARG_T="-t 1"
ARG_NUMPY="-numpy 1"
ARG_WELD="-weld 1"

sum_call_run(){
  if [ $# -ne 1 ]; then
    echo "Error: sum_call_run arg is 1."
    return 0
  fi
  CALL_RUNS=`grep 'call run' $1 | cut -d: -f2 | cut -d' ' -f2`
  SUM_EXP="0.0"
  for call_run in $CALL_RUNS
  do
    SUM_EXP=`echo $SUM_EXP + $call_run`
  done
  echo $SUM_EXP | bc
}

### Numpy
if [ ${ORIG_EXEC} -eq 1 ]; then
  python ${EXE_B} ${ARG_N} ${ARG_T} ${ARG_NUMPY} > runlog.numpy 2>&1
fi

### Host Weld
if [ ${HOSTWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=-1
  python ${EXE_B} ${ARG_N} ${ARG_T} ${ARG_WELD} > runlog.hostweld 2>&1
fi

### VE-Weld
if [ ${VEWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=${EXEC_VE_NODE_NUMBER}
  python ${EXE_B} ${ARG_N} ${ARG_T} ${ARG_WELD} > runlog.veweld 2>&1
fi

if [ ${HOSTWELD_EXEC} -eq 1 -a ${VEWELD_EXEC} -eq 1 ];then
  grep 'result=' runlog.hostweld > result.hostweld
  grep 'result=' runlog.veweld > result.veweld
  diff result.hostweld result.veweld > /dev/null
  if [ $? -eq 0 ]; then
    echo "nbody: OK: host-weld(" `sum_call_run runlog.hostweld` "), ve-weld(" `sum_call_run runlog.veweld` ")"
  else
    echo "nbody: NG: host-weld(" `cat result.hostweld` "),ve-weld(" `cat result.veweld` ")"
  fi
  rm result.hostweld result.veweld
fi
  
