#!/bin/bash

## Call me from ANALYSIS/2D_J-Coupling

if [ "$1" = "" ] ; then
	echo "specify number of runs on the command line"
	exit
fi

s=1
while [ "$s" -le "4" ] ; do 
	i=1
	if [ -e "sorted_2d_${s}.txt" ] ; then 
		rm "sorted_2d_${s}.txt"
	fi
	if [ -e "sorting_temp" ] ; then
		rm "sorting_temp"
	fi
	while [ "$i" -le "$1" ] ; do
		paste ${s}_${i} JOUT_${s}_${i} >> sorting_temp
        	i=$((i+1))
	done
	sort -n -k 3 < sorting_temp > sorted_2d_${s}.txt
	rm sorting_temp
        s=$((s+1))
done
