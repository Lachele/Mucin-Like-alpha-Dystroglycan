#!/bin/bash

vmdpath="/programs/bin/vmd"

i=1
while [ $i -le 32 ] ; do
	echo "${vmdpath} input/Single.parm7 ${i}/prod.nc"
	${vmdpath} input/Single.parm7 ${i}/prod.nc
	if [ -e ${i}/prod2.nc ] ; then 
		echo "${vmdpath} input/Single.parm7 ${i}/prod2.nc"
		${vmdpath} input/Single.parm7 ${i}/prod2.nc
	fi
	i=$((i+1))
done
