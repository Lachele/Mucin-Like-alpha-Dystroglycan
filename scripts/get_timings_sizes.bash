#!/bin/bash

. ../REFRESH_SETUP

if [ ! -e SUMMARIES ] ; then
	mkdir SUMMARIES
fi
OUTFILE="SUMMARIES/Run_Info.txt"
echo "# Summary of simulation lengths and system sizes " > ${OUTFILE}

ATOMS="getting atoms failed"
INFO="getting info failed"

i=1
while [ $i -le $NUMRUNS ] ; do
	echo "Working on run $i"
	if [ -e ../${i}/prod4.info ] ; then 
		#ATOMS="$(head -2 ../${i}/prod4.rst7 | tail -1 | cut -c -5)" 
		INFO="$(grep "NSTEP" ../${i}/prod4.info)"
	elif [ -e ../${i}/prod3.info ] ; then 
		#ATOMS="$(head -2 ../${i}/prod3.rst7 | tail -1 | cut -c -5)" 
		INFO="$(grep "NSTEP" ../${i}/prod3.info)"
	elif [ -e ../${i}/prod2.info ] ; then 
		#ATOMS="$(head -2 ../${i}/prod2.rst7 | tail -1 | cut -c -5)" 
		INFO="$(grep "NSTEP" ../${i}/prod2.info)"
	else
		#ATOMS="$(head -2 ../${i}/prod.rst7 | tail -1 | cut -c -5)"
		INFO="$(grep "NSTEP" ../${i}/prod.info)"
	
	fi
	echo "RUN = ${i}  NATOM = ${ATOMS}  ${INFO}" >> ${OUTFILE}
	i=$((i+1))
done
