#!/bin/bash
export AMBERHOME=/programs/amber12
export PTRAJ=${AMBERHOME}/bin/ptraj

testwrite=no

for run in alpb2 alpb7 Diel igb1 igb2 igb5 igb7 igb8 ; do
	echo "trajin d4g_${run}_ALL_FRAMES.mdcrd" > ptraj_HH-OO_${run}.in
	for site in 1 2 3 4 ; do
		res1=$((site+3))
		res2=$((site+11))
		echo "
distance H-H${site} :${res1}@H :${res2}@H2N out Distances_H-H_${site}_${run}.txt
distance O-O${site} :${res1}@OG1 :${res1}@O out Distances_O-O_${site}_${run}.txt
" >> ptraj_HH-OO_${run}.in
	done
	echo "go" >> ptraj_HH-OO_${run}.in
	if [ "$testwrite" = "no" ] ; then
		${PTRAJ} ../../input/1.parm7 < ptraj_HH-OO_${run}.in
	fi
done

if [ "$testwrite" = "yes" ] ; then
	exit
fi

for run in alpb2 alpb7 Diel igb1 igb2 igb5 igb7 igb8 ; do

	for site in 1 2 3 4 ; do
		./make2Dbins Distances_H-H_${site}_${run}.txt Distances_O-O_${site}_${run}.txt HH-OO_${site}_${run} 100 
	done
done

for site in 1 2 3 4 ; do
	./make2Dbins Distance_H-H_Explicit_${site}_cpptraj.out Distance_O-O_Explicit_${site}_cpptraj.out HH-OO_${site}_Expl 100
done

