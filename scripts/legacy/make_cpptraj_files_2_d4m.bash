#!/bin/bash

MAXNUM=32
i=1
CPPtrajPrefix="size_cpptraj"
GREPME=0MA

export AMBERHOME=/programs/amber12

while [ $i -le $MAXNUM ] ; do

## Check that prods.nc was generated already; die if not
	if [ !-e "../${i}/prods.nc" ] ; then 
		echo "d4m needs prods.nc created before running this."
		exit
	fi

## Generate the cpptraj input script
	echo "trajin ../${i}/prods.nc  [traj${i}] " > ${CPPtrajPrefix}_${i}.in 
	if [ -e "../${i}/prod2s.nc" ] ; then
		echo "trajin ../${i}/prod2s.nc  [traj${i}] " > ${CPPtrajPrefix}_${i}.in
	fi
	echo "" >> ${CPPtrajPrefix}_${i}.in 
	echo "# Get N-N distance info " >> ${CPPtrajPrefix}_${i}.in 
	echo "" >> ${CPPtrajPrefix}_${i}.in 
	echo "distance N-N :4@N :8@N out N-N_distance_t${i}.dat " >> ${CPPtrajPrefix}_${i}.in 
	echo "" >> ${CPPtrajPrefix}_${i}.in 

	echo "# Generate H-bond info " >> ${CPPtrajPrefix}_${i}.in 
	echo "" >> ${CPPtrajPrefix}_${i}.in 
	echo "hbond hbonds out HBONDS_t${i}.dat avgout HBONDS-Avg_t${i}.dat" >> ${CPPtrajPrefix}_${i}.in

	echo "" >> ${CPPtrajPrefix}_${i}.in 
	echo "go" >> ${CPPtrajPrefix}_${i}.in

## Run the cpptraj script
	${AMBERHOME}/bin/cpptraj -i ${CPPtrajPrefix}_${i}.in -p ../input/Single.parm7

	i=$((i+1))
done

## Concatenate all the distance files and grep OLT from the H-bond average info
if [ -e N-N_distance_All_t00.dat ] ; then
	rm N-N_distance_All_t00.dat
fi
if [ -e HBONDS-Avg_short_t00.dat ] ; then
	rm HBONDS-Avg_short_t00.dat
fi
i=1
while [ $i -le $MAXNUM ] ; do
	cat N-N_distance_t${i}.dat >> N-N_distance_All_t00.dat
	grep OLT HBONDS-Avg_t${i}.dat | grep ${GREPME} >> HBONDS-Avg_short_t00.dat
	i=$((i+1))
done
