#!/bin/bash

vmdpath="/programs/bin/vmd"
searchstring="_SolCl.parm7"
##searchstring=".parm7"
psuffix=".parm7"
rsuffix=".rst7"

for i in $(ls *${searchstring}) ; do
	basename=${i%${psuffix}} 
	echo "${vmdpath} ${basename}${psuffix} ${basename}${rsuffix}"
	${vmdpath} ${basename}${psuffix} ${basename}${rsuffix}
done
