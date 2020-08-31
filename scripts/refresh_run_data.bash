#!/bin/bash

# call me from the DLIVE directory used for analysis

MasterInfoPath=/e05/lachele/Eliot/DLIVE

for i in d4g d4m protein ; do
	cd $i
	pwd
	. ./REFRESH_SETUP
	echo "There are $NUMRUNS runs"
	j=1
	while [ $j -le $NUMRUNS ] ; do
		if [ ! -e "$j" ] ; then
			echo "creating directory $j"
			mkdir $j
		fi
		cp $MasterInfoPath/$i/$j/prod*.info ./$j
		cp $MasterInfoPath/$i/$j/prod*.nc ./$j
		j=$((j+1))
	done
	cd ..
done
