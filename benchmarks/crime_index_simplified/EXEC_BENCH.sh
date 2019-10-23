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
WELD_NUM_THREADS=1

export WELD_NUM_THREADS WELD_COMPILATION_STATS WELD_RUN_STATS WELD_NCC_CFLAGS VE_NODE_NUMBER

### Host Weld
if [ ${HOSTWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=-1
  ./bench -s 100 -f data/us_cities_states_counties_sf=%d.csv > runlog.hostweld 2>&1
fi

### VE-Weld
if [ ${VEWELD_EXEC} -eq 1 ]; then
  VE_NODE_NUMBER=${EXEC_VE_NODE_NUM}
  ./bench -s 100 -f data/us_cities_states_counties_sf=%d.csv > runlog.veweld 2>&1
fi

if [ ${HOSTWELD_EXEC} -eq 1 -a ${VEWELD_EXEC} -eq 1 ];then
  grep 'result=' runlog.hostweld | grep Grizzly | cut -d= -f2 | cut -d')' -f1 > result.hostweld
  grep 'result=' runlog.veweld | grep Grizzly | cut -d= -f2 | cut -d')' -f1 > result.veweld
  diff result.hostweld result.veweld > /dev/null
  if [ $? -eq 0 ]; then
    echo "crime_index_simplified: OK"
  else
    echo "crime_index_simplified: NG: host-weld(" `cat result.hostweld` "),ve-weld(" `cat result.veweld` ")"
  fi
  rm result.hostweld result.veweld
fi
