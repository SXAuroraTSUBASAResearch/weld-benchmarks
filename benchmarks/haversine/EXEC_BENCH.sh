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
WELD_NCC_CFLAGS="-ZV -w -fdiag-vector=2"

NUM_SCALE="1000"

export WELD_COMPILATION_STATS WELD_RUN_STATS WELD_NCC_CFLAGS VE_NODE_NUMBER

EXE_B=main.py

VEWELDFLAG=1
HOSTWELDFLAG=1
NUMPYFLAG=0

if [ ! -d RUNLOG ]; then
  mkdir RUNLOG
fi

if [ ! -d RES ]; then
  mkdir RES
fi

if [ ${ORIG_EXEC} -eq 1 ]; then
### numpy
#  echo "python ${EXE_B} -s ${NUM_SCALE} -numpy 1"
        python ${EXE_B} -s ${NUM_SCALE} -numpy 1 > RUNLOG/runlog.numpy${NUM_SCALE} 2>&1
        mv lats${NUM_SCALE} RES/lats${NUM_SCALE}.numpy
        mv lons${NUM_SCALE} RES/lons${NUM_SCALE}.numpy
fi

### Host Weld
if [ ${HOSTWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER="-1"
#  echo "python ${EXE_B} -s ${NUM_SCALE} -weld 1"
        python ${EXE_B} -s ${NUM_SCALE} -weld 1 > RUNLOG/runlog.hostweld${NUM_SCALE} 2>&1
        mv lats${NUM_SCALE} RES/lats${NUM_SCALE}.hostweld
        mv lons${NUM_SCALE} RES/lons${NUM_SCALE}.hostweld
fi

### VE-Weld
if [ ${VEWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=${EXEC_VE_NODE_NUMBER}
#  echo "python ${EXE_B} -s ${NUM_SCALE} -weld 1"
        python ${EXE_B} -s ${NUM_SCALE} -weld 1 > RUNLOG/runlog.veweld${NUM_SCALE} 2>&1
        mv lats${NUM_SCALE} RES/lats${NUM_SCALE}.veweld
        mv lons${NUM_SCALE} RES/lons${NUM_SCALE}.veweld
fi

if [ ${HOSTWELD_EXEC} -eq 1 -a ${VEWELD_EXEC} -eq 1 ]; then
  diff RES/lats${NUM_SCALE}.hostweld RES/lats${NUM_SCALE}.veweld > /dev/null
  lats_flag=$?

  diff RES/lons${NUM_SCALE}.hostweld RES/lons${NUM_SCALE}.veweld > /dev/null
  lons_flag=$?

  if [ $lats_flag -eq 0 -a $lons_flag -eq 0 ]; then
    echo "haversine: OK"
  else
    echo "haversine: NG"
  fi
fi

