#!/bin/bash


#runs='Diel pb igb1 igb2 igb5 igb7 igb8 alpb1 alpb2 alpb5 alpb7'
#runs='Diel igb1 igb2 igb5 igb7 igb8'
#runs='alpb2 alpb7'
runs='alpb1 alpb5'

for run in $runs ; do 
	i=1
	iamhere=$(pwd)
	itisthere="../../NoWat/${run}"
	Output="d4g_${run}_ALL_FRAMES.mdcrd"
	echo "Concatenated IS trajectory for special purpose" > ${Output}
echo "
itisthere is ${itisthere}
"
	while [ "$i" -le "32" ] ; do
		if [ ! -e "${itisthere}/${i}/prod.mdcrd" ] ; then
			( cd ${itisthere}/${i} && ln -s prod.nc prod.mdcrd )
			#( cd ${itisthere}/${i} && ls prod.nc prod.mdcrd )
		fi
        	frames=$(wc -l ${itisthere}/${i}/prod.mdcrd | cut -d ' ' -f1)
#echo "Frames is ${frames}"
        	frames=$((frames-1))
        	tail -n ${frames} ${itisthere}/${i}/prod.mdcrd >> ${Output}
#echo "    and is now $frames"
        	i=$((i+1))
	done
done
