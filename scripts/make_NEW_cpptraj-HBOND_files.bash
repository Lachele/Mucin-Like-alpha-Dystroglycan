#!/bin/bash

# This should be run from the DLIVE/${IAM}/ANALYSIS directory
. ../cpptraj_setup.bash

#export AMBERHOME=/programs/amber
#export AMBERHOME=/programs/amber12  -- this is no longer installed....
source /programs/amber16/amber.sh
i=1
j=1
PTRAJ_Headers="" # the trajin bits at the top of each file

TESTWRITE="no" # yes=only make files; no=do the runs

echo "MAXRUNS is ${MAXRUNS}"

# Make directories if they aren't there
if [ ! -e "NEW_HBOND" ] ; then
	mkdir NEW_HBOND
fi

while [ "$i" -le "$MAXRUNS" ] ; do
	echo "checking for ../${i}/"
	if [ ! -d "../${i}/" ] ; then
		i=$((i+1))
		continue
	fi
	echo "Found ../${i}/ and going forward."
	PTRAJ_Headers="trajin ../${i}/prod_all_fixed.crd" 

	echo -e ${PTRAJ_Headers} > NEW_Hbond_cpptraj_${i}.in
	echo "# Generate H-bond info " >> NEW_Hbond_cpptraj_${i}.in
	echo "hbond hbonds out NEW_HBOND/HBONDS_t${i}.dat angle 90 dist 3.9 avgout NEW_HBOND/HBONDS-Avg_t${i}.dat" >> NEW_Hbond_cpptraj_${i}.in
	echo "go" >> NEW_Hbond_cpptraj_${i}.in

	## Run the cpptraj script 
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/cpptraj -i NEW_Hbond_cpptraj_${i}.in -p ../input/Single.parm7
fi
	i=$((i+1))
	j=1
done

mv *cpptraj*.in PTRAJ_INPUTS



