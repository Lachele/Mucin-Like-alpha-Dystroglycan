#!/bin/bash

##
## Call me from runset/ANALYSIS
##

## Load in run info
. ../cpptraj_setup.bash
## Check for required directory
if [ ! -d "RMSD" ] ; then 
	echo "no RMSD directory -- can't do my job"
	exit
fi

cd RMSD

## Set gnuplot common info
GNUPLOT_HEADER="# gnuplot input file made by concatenate_RMSD_files.bash on $(date)\n
reset\n
unset key\n
set title ""\n
set size ratio 3\n
set xlabel \"Reference structure index\"\n
set ylabel \"MD simulation snapshot number\"\n
set cblabel \"RMSD\"\n
set cbrange [ 0.5000 : 0.8000 ] noreverse nowriteback\n
set palette rgbformulae 2, 3, 3\n
set yra [0:]\n
set grid xtics front\n
set grid mxtics front"


i=1
plotset=1
totalframesB=0
totalframesS=0
while [ $i -le $MAXRUNS ] ; do 
	if [ $(( (i-1) % 10 )) -eq 0 ] ; then
		## Start gnuplot file(s)
		echo -e $GNUPLOT_HEADER > Back_rmsd_all-all_${plotset}.plot
		if [ "${IAM}" != "prot" ] ; then 
			echo -e $GNUPLOT_HEADER > Sugr_rmsd_all-all_${plotset}.plot
		fi
	fi
	NumFrames=$(wc -l Back_rmsd_t${i}_r-all.dat | cut -d ' ' -f 1)
	totalframesB=$((totalframesB+NumFrames))
	echo "set arrow $i from -1,$totalframesB to $MAXRUNS,$totalframesB lw 3 lt 0 front nohead" >> Back_rmsd_all-all_${plotset}.plot
	echo "set label $i \"R${i}\" rotate center at -3,$(( totalframesB-(NumFrames/2) ))" >> Back_rmsd_all-all_${plotset}.plot
	sed '/Frame/d' < Back_rmsd_t${i}_r-all.dat | cut -c 9- >> Back_rmsd_all-all_${plotset}.dat
	if [ "${IAM}" = "prot" ] ; then  
		i=$((i+1))
		continue
	fi
	NumFrames=$(wc -l Sugr_rmsd_t${i}_r-all.dat | cut -d ' ' -f 1)
	totalframesS=$((totalframesS+NumFrames))
	echo "set arrow $i from -1,$totalframesS to $MAXRUNS,$totalframesS lw 3 lt 0 front nohead" >> Sugr_rmsd_all-all_${plotset}.plot
	echo "set label $i \"R${i}\" rotate center at -3,$(( totalframesS-(NumFrames/2) ))" >> Sugr_rmsd_all-all_${plotset}.plot
	sed '/Frame/d' < Sugr_rmsd_t${i}_r-all.dat | cut -c 9- >> Sugr_rmsd_all-all_${plotset}.dat

        if [ $(( (i-1) % 10 )) -eq 0 ] ; then 
		echo "plot \"Back_rmsd_all-all_${plotset}.dat\" matrix with image" >> Back_rmsd_all-all_${plotset}.plot
		if [ "${IAM}" != "prot" ] ; then 
			echo "plot \"Sugr_rmsd_all-all_${plotset}.dat\" matrix with image" >> Sugr_rmsd_all-all_${plotset}.plot
		fi
		plotset=$((plotset+1))
	fi
	i=$((i+1))
done

