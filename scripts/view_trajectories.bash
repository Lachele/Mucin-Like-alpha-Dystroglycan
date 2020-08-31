#!/bin/bash

. cpptraj_setup.bash

vmdpath="/programs/bin/vmd"
PARM="input/Single.parm7"

PROD="prod"
if [ "${IAM}" = "0MA" ] ; then 
	PROD="prods"
fi

i=1
while [ $i -le $MAXRUNS ] ; do
	echo "${vmdpath} ${PARM} ${i}/${PROD}.nc"
	${vmdpath} ${PARM} ${i}/${PROD}.nc
	for j in 2 3 4; do 
		if [ -e ${i}/${PROD}2.nc ] ; then 
			echo "${vmdpath} ${PARM} ${i}/${PROD}2.nc"
			${vmdpath} ${PARM} ${i}/${PROD}2.nc
		fi
	done
	i=$((i+1))
done
