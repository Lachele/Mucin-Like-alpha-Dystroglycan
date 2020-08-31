#!/bin/bash

. ../REFRESH_SETUP

EXE="../../scripts/src/statistics/getSDMInfo"

for i in $(ls JCOUP/*Details JCOUP/*Plot) ; do
	rm $i
done
for i in $(ls JCOUP/*ALL*) ; do
	$EXE  $i
	mv SDMDetails.txt ${i}_Details
	mv SDMPlotInfo.txt ${i}_Plot
done

for i in $(ls 2D_J-Coupling/*Details 2D_J-Coupling/*Plot) ; do
	rm $i
done
for i in $(ls 2D_J-Coupling/*ALL*) ; do
	$EXE  $i
	mv SDMDetails.txt ${i}_Details
	mv SDMPlotInfo.txt ${i}_Plot
done

for i in $(ls DIST/*Details DIST/*Plot DIST/*ALL) ; do
	rm $i
done
echo "# All distances for EndsLYS" > DIST/Distances_EndsLYS.dat_ALL
for i in $(ls DIST/Distances_EndsLYS*.dat) ; do
	$EXE $i ptraj
	cat $i >> DIST/Distances_EndsLYS.dat_ALL
	mv SDMDetails.txt ${i}_Details
	mv SDMPlotInfo.txt ${i}_Plot
done
echo "# All distances for EndsNHE" > DIST/Distances_EndsNHE.dat_ALL
for i in $(ls DIST/Distances_EndsNHE*.dat) ; do
	$EXE $i ptraj
	cat $i >> DIST/Distances_EndsNHE.dat_ALL
	mv SDMDetails.txt ${i}_Details
	mv SDMPlotInfo.txt ${i}_Plot
done
echo "# All distances for N-N" > DIST/Distances_N-N.dat_ALL
for i in $(ls DIST/Distances_N-N*.dat) ; do
	$EXE $i ptraj
	cat $i >> DIST/Distances_N-N.dat_ALL
	mv SDMDetails.txt ${i}_Details
	mv SDMPlotInfo.txt ${i}_Plot
done
# Now for the collected data
for i in $(ls DIST/Distances_*ALL) ; do
	$EXE $i ptraj
	mv SDMDetails.txt ${i}_Details
	mv SDMPlotInfo.txt ${i}_Plot
done
