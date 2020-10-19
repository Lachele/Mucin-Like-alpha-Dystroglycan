#!/bin/bash

# This script does calculations relevant to the 4-way interaction between 
#	the GalNAc and the backbone.   It does the calculations for both
#	the regular runs and for the with-waters equilibrated runs.

# This should be run from the DLIVE/${IAM}/ANALYSIS directory
. ../cpptraj_setup.bash

export AMBERHOME=/programs/amber16
i=1
j=1
Headers="" # the trajin bits at the top of each file
EQ_Headers="" # the trajin bits at the top of each file

TESTWRITE="no" # yes=only make files; no=do the runs

echo "MAXRUNS is ${MAXRUNS}"

# Make directories if they aren't there
if [ ! -e "4WAY" ] ; then
	mkdir 4WAY
fi

while [ "$i" -le "$MAXRUNS" ] ; do
	echo "checking for ../${i}/"
	if [ ! -d "../${i}/" ] ; then
		echo "Can't find the ${i} run directory"
		exit
	fi
	echo "checking for RADIAL/equil_all_${i}.mdcrd"
	if [ ! -d "../${i}/" ] ; then
		exit
		echo "Can't find the eq mdcrd file for ${i}"
	fi

	echo "Found everything for ${i} and going forward."
	if [ -e  4WAY/EQ_All_t${i}.dat ] ; then
		rm 4WAY/EQ_All_t${i}.dat
	fi
	if [ -e  4WAY/All_t${i}.dat ] ; then
		rm 4WAY/All_t${i}.dat
	fi

	EQ_Headers="trajin RADIAL/equil_all_${i}.mdcrd" 
	echo -e ${EQ_Headers} > EQ_4Way_cpptraj_${i}.in
	echo "# Get H-H2N distance info " >> EQ_4Way_cpptraj_${i}.in 
	echo "distance H-H2N_4 :4@H :12@H2N out 4WAY/EQ_HH-4_t${i}.dat " >> EQ_4Way_cpptraj_${i}.in 
	echo "distance H-H2N_5 :5@H :13@H2N out 4WAY/EQ_HH-5_t${i}.dat " >> EQ_4Way_cpptraj_${i}.in 
	echo "distance H-H2N_6 :6@H :14@H2N out 4WAY/EQ_HH-6_t${i}.dat " >> EQ_4Way_cpptraj_${i}.in 
	echo "distance H-H2N_7 :7@H :15@H2N out 4WAY/EQ_HH-7_t${i}.dat " >> EQ_4Way_cpptraj_${i}.in 
	echo "# Get O-OG1 distance info " >> EQ_4Way_cpptraj_${i}.in 
	echo "distance O-OG1_4 :4@O :4@OG1 out 4WAY/EQ_OO-4_t${i}.dat " >> EQ_4Way_cpptraj_${i}.in 
	echo "distance O-OG1_5 :5@O :5@OG1 out 4WAY/EQ_OO-5_t${i}.dat " >> EQ_4Way_cpptraj_${i}.in 
	echo "distance O-OG1_6 :6@O :6@OG1 out 4WAY/EQ_OO-6_t${i}.dat " >> EQ_4Way_cpptraj_${i}.in 
	echo "distance O-OG1_7 :7@O :7@OG1 out 4WAY/EQ_OO-7_t${i}.dat " >> EQ_4Way_cpptraj_${i}.in 
	echo "go" >> EQ_4Way_cpptraj_${i}.in 
	echo "#     Num  H-H2N_4      Num  H-H2N_5      Num  H-H2N_6      Num  H-H2N_7      Num  O-OG1_4        Num  O-OG1_5        Num  O-OG1_6        Num  O-OG1_7  " > 4WAY/EQ_All_t${i}.dat

	Headers="trajin ../${i}/prod_all_fixed.crd" 
	echo -e ${Headers} > 4Way_cpptraj_${i}.in
	echo "# Get H-H2N distance info " >> 4Way_cpptraj_${i}.in 
	echo "distance H-H2N_4 :4@H :12@H2N out 4WAY/HH-4_t${i}.dat " >> 4Way_cpptraj_${i}.in 
	echo "distance H-H2N_5 :5@H :13@H2N out 4WAY/HH-5_t${i}.dat " >> 4Way_cpptraj_${i}.in 
	echo "distance H-H2N_6 :6@H :14@H2N out 4WAY/HH-6_t${i}.dat " >> 4Way_cpptraj_${i}.in 
	echo "distance H-H2N_7 :7@H :15@H2N out 4WAY/HH-7_t${i}.dat " >> 4Way_cpptraj_${i}.in 
	echo "# Get O-OG1 distance info " >> 4Way_cpptraj_${i}.in 
	echo "distance O-OG1_4 :4@O :4@OG1 out 4WAY/OO-4_t${i}.dat " >> 4Way_cpptraj_${i}.in 
	echo "distance O-OG1_5 :5@O :5@OG1 out 4WAY/OO-5_t${i}.dat " >> 4Way_cpptraj_${i}.in 
	echo "distance O-OG1_6 :6@O :6@OG1 out 4WAY/OO-6_t${i}.dat " >> 4Way_cpptraj_${i}.in 
	echo "distance O-OG1_7 :7@O :7@OG1 out 4WAY/OO-7_t${i}.dat " >> 4Way_cpptraj_${i}.in 
	echo "go" >> 4Way_cpptraj_${i}.in 
	echo "#     Num  H-H2N_4      Num  H-H2N_5      Num  H-H2N_6      Num  H-H2N_7      Num  O-OG1_4        Num  O-OG1_5        Num  O-OG1_6        Num  O-OG1_7  " > 4WAY/All_t${i}.dat

	## Run the ptraj script 
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/ptraj ../input/${i}_SolCl.parm7 < EQ_4Way_cpptraj_${i}.in 
fi
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/ptraj ../input/Single.parm7 < 4Way_cpptraj_${i}.in 
fi

	i=$((i+1))
	j=1
done

if [ ! -e "PTRAJ_INPUTS" ] ; then
	mkdir PTRAJ_INPUTS
fi
mv *cpptraj*.in PTRAJ_INPUTS

if [ "${TESTWRITE}" = "yes" ] ; then
	exit
fi

## Paste and concatenate files
i=1
while [ "$i" -le "$MAXRUNS" ] ; do
	paste 4WAY/HH-4_t${i}.dat 4WAY/HH-5_t${i}.dat 4WAY/HH-6_t${i}.dat 4WAY/HH-7_t${i}.dat 4WAY/OO-4_t${i}.dat 4WAY/OO-5_t${i}.dat 4WAY/OO-6_t${i}.dat 4WAY/OO-7_t${i}.dat >> 4WAY/All_t${i}.dat
	paste 4WAY/EQ_HH-4_t${i}.dat 4WAY/EQ_HH-5_t${i}.dat 4WAY/EQ_HH-6_t${i}.dat 4WAY/EQ_HH-7_t${i}.dat 4WAY/EQ_OO-4_t${i}.dat 4WAY/EQ_OO-5_t${i}.dat 4WAY/EQ_OO-6_t${i}.dat 4WAY/EQ_OO-7_t${i}.dat >> 4WAY/EQ_All_t${i}.dat
	i=$((i+1))
done

if [ -e 4WAY/All_t00.dat ] ; then
	rm 4WAY/All_t00.dat
fi
if [ -e 4WAY/EQ_All_t00.dat ] ; then
	rm 4WAY/EQ_All_t00.dat
fi

i=1
while [ $i -le $MAXRUNS ] ; do
	cat 4WAY/All_t${i}.dat >> 4WAY/All_t00.dat
	cat 4WAY/EQ_All_t${i}.dat >> 4WAY/EQ_All_t00.dat
	i=$((i+1))
done
