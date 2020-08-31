#!/bin/bash

###
###   This script is only for the GalNAc runs.  It greps out the energy info from
###      the equil.o file into a plottable form.  It also copies the equil.o file
###      over from the current location of the original MD data.
###
###
###      Call me from d4g/ANALYSIS 
###
###

NUMRUNS=32
#NUMRUNS=1

if [ ! -d EQUIL ] ; then 
	mkdir -p EQUIL/PLOTS
fi
i=1
while [ $i -le $NUMRUNS ] ; do
	cp /e05/lachele/Eliot/DLIVE/d4g/${i}/equil.o  ../${i}/
	grep -A 20 "A V E R A G E S   O V E R    1000 S T E P S" ../${i}/equil.o  > tmp0
	grep -A 6 "A V E R A G E S   O V E R    1000 S T E P S" tmp0 | grep Etot > tmp1
	grep -A 6 "R M S  F L U C T U A T I O N S" tmp0 | grep Etot > tmp2
	paste tmp1 tmp2 > EQUIL/Etot_${i}.dat
	echo "# gnuplot input file written by gather_equil_E_info.bash
set term post enh solid color
set output \"Etot_${i}.eps\"
plot \"../Etot_${i}.dat\" using 0:3:12 with yerr
" > EQUIL/PLOTS/Etot_${i}.plot
	cd EQUIL/PLOTS 
	gnuplot Etot_${i}.plot
	ps2pdf Etot_${i}.eps
	convert Etot_${i}.eps Etot_${i}.jpg
	cd ../../
	i=$((i+1))
done
rm tmp0 tmp1 tmp2

