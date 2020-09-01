#!/bin/bash

vmdpath="/programs/bin/vmd"
PARM="input/Single.parm7"
#PARM="input/plus8water.parm7"
#PROD="prod"
PROD="prods"

i=1
while [ $i -le 32 ] ; do
	echo "${vmdpath} ${PARM} ${i}/${PROD}.nc"
	${vmdpath} ${PARM} ${i}/${PROD}.nc
	if [ -e ${i}/${PROD}2.nc ] ; then 
		echo "${vmdpath} ${PARM} ${i}/${PROD}2.nc"
		${vmdpath} ${PARM} ${i}/${PROD}2.nc
	fi
	i=$((i+1))
done
