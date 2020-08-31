#!/bin/bash

# This should be run from the DLIVE/${IAM}/ANALYSIS directory
. ../cpptraj_setup.bash

if [ "${IAM}" = "prot" ] ; then
	echo "Can't run me on the peptide.  For glycans only."
	exit
fi

export AMBERHOME=/programs/amber12
i=1
j=1
iB=1
iS=1
crdcnt=1

PTRAJ_Headers="" # the trajin bits at the top of each file

TESTWRITE="no" # yes=only make files; no=do the runs

echo "MAXRUNS is ${MAXRUNS}"

# Make directories if they aren't there
if [ ! -d "RMSD" ] ; then
	echo "Really?  The RMSD directory doesn't exist?  Are you sure you're in the right place?"
	exit
fi

while [ "$i" -le "$MAXRUNS" ] ; do
	echo "checking for ../${i}/"
	if [ ! -d "../${i}/" ] ; then
		i=$((i+1))
		continue
	fi
	echo "Found ../${i}/ and going forward."
	PTRAJ_Headers="trajin ../${i}/prod_all_fixed.crd" 

	echo "# Generate RMSDs for THR backbone and for Sugar heavy atoms" > Sugr-Bak_RMSD_cpptraj_${i}.in 
	echo -e ${PTRAJ_Headers} >> Sugr-Bak_RMSD_cpptraj_${i}.in
	while [ "$j" -le "$MAXRUNS" ] ; do 
		iB=4 
		while  [ "$iB" -le "7" ] ; do
			iS=$((iB+8))
			echo "reference ../input/${j}.rst7 [ref${j}]" >> Sugr-Bak_RMSD_cpptraj_${i}.in
			echo "rms Back_${j}_${iB} :${iB}&@CA,C,O,N,H out RMSD/B_Sugr-Bak_rmsd_t${i}_${iB}_r-all.dat ref [ref${j}] " >> Sugr-Bak_RMSD_cpptraj_${i}.in
			echo "rms Sugr_${j}_${iS} :${iS}&@C1,C2,C3,C4,C5,O5 out RMSD/S_Sugr-Bak_rmsd_t${i}_${iS}_r-all.dat nofit ref [ref${j}] " >> Sugr-Bak_RMSD_cpptraj_${i}.in
			if [ "$crdcnt" -eq "200" ] ; then
				echo "trajout S_Sugr-Bak_rmsd_t${i}_${iS}_ref_${j}.mdcrd" >> Sugr-Bak_RMSD_cpptraj_${i}.in
			fi
			echo "" >> Sugr-Bak_RMSD_cpptraj_${i}.in 
			iB=$((iB+1))
		done
		j=$((j+1))
		if [ "$crdcnt" -eq "200" ] ; then
			crdcnt=1
		else
			crdcnt=$((crdcnt+1))
		fi
	done 
	echo "go" >> Sugr-Bak_RMSD_cpptraj_${i}.in
	
	## Run the cpptraj script 
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/cpptraj -i Sugr-Bak_RMSD_cpptraj_${i}.in -p ../input/Single.parm7
fi

	i=$((i+1))
	j=1
done

mv *cpptraj*.in PTRAJ_INPUTS

exit

