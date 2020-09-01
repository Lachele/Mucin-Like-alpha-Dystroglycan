#!/bin/bash

OUTFILE="SUMMARIES/Run_Info.txt"
echo "# Summary of simulation lengths and system sizes " > ${OUTFILE}

ATOMS="0"
INFO=""

i=1
while [ $i -le 32 ] ; do
	echo "Working on run $i"
	if [ -e ../${i}/prod2.info ] ; then 
		ATOMS="$(head -2 ../${i}/prod2.rst7 | tail -1 | cut -c -5)" 
		INFO="$(grep "NSTEP" ../${i}/prod2.info)"
	else
		ATOMS="$(head -2 ../${i}/prod.rst7 | tail -1 | cut -c -5)"
		INFO="$(grep "NSTEP" ../${i}/prod.info)"
	
	fi
	echo "RUN = ${i}  NATOM = ${ATOMS}  ${INFO}" >> ${OUTFILE}
	i=$((i+1))
done
