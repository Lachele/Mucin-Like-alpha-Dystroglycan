#!/bin/bash

##
##

export GNUPLOT=/programs/gnuplot-5.0.rc3/bin/gnuplot

testwrite=no

TOP="set xtics border in scale 0,0 mirror norotate  autojustify
set ytics border in scale 0,0 mirror norotate  autojustify
unset colorbox
set xrange [1.0:8.0]
set yrange [2.0:5.0]
set grid x
set grid y
set xla \"H-H distance\"
set yla \"O-O distance\"
set grid front
#set size square
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
"



for run in alpb2 alpb7 Diel Expl igb1 igb2 igb5 igb7 igb8 ; do
	for site in 1 2 3 4 ; do
		PLOTFILE="HH-OO_heat_${site}_${run}.plot"
		echo "${TOP}" > ${PLOTFILE}
		echo "
set title \"THR ${site}, ${run}\"
set term post enh color 16
set output \"HH-OO_heat_${site}_${run}.ps\"
plot \"HH-OO_${site}_${run}_XYZ_bins.txt\" using 1:2:6 with image
" >> ${PLOTFILE}
		if [ "$testwrite" = "no" ] ; then
			${GNUPLOT} ${PLOTFILE}
			convert -rotate 90 HH-OO_heat_${site}_${run}.ps HH-OO_heat_${site}_${run}.jpg
		fi
	done
done


