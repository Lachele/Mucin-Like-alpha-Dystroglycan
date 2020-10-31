#!/bin/bash

# This script does calculations relevant to the 4-way interaction between 
#	the GalNAc and the backbone.   It does the calculations for both
#	the regular runs and for the with-waters equilibrated runs.

### This should be run from the TREATED/d4g/ANALYSIS directory

. ../cpptraj_setup.bash

# This analysis was performed on Lachele's personal laptop
export AMBERHOME=/programs/amber-18-with-patches
i=1
j=1
Headers="" # the trajin bits at the top of each file
EQ_Headers="" # the trajin bits at the top of each file

#TESTWRITE="yes" # yes=only make files; no=do the runs
TESTWRITE="no" # yes=only make files; no=do the runs

echo "MAXRUNS is ${MAXRUNS}"


# Make directories if they aren't there
OUTDIR="4WAY_HOH"
if [ ! -e "${OUTDIR}" ] ; then
	mkdir ${OUTDIR}
fi

if [ ! -d "RADIAL" ] ; then
	echo "Can't find the RADIAL directory"
	exit
fi
site=( "4" "5" "6" "7" )
pRes=( "4" "5" "6" "7" )
sRes=( "12" "13" "14" "15" )
while [ "$i" -le "$MAXRUNS" ] ; do
	## echo "checking for needed input files for run ${i}"
	## echo "checking for ../${i}/"
	if [ ! -d "../${i}/" ] ; then
		echo "Can't find the ${i} run directory"
		exit
	fi
	## echo "checking for ../${i}/prod_all_fixed.crd"
	if [ ! -e "../${i}/prod_all_fixed.crd" ] ; then
		echo "Can't find the prod_all_fixed.crd file for run ${i}"
		exit
	fi
	TRAJECTORYIN="../${i}/prod_all_fixed.crd"
	## echo "checking for RADIAL/equil_all_${i}.mdcrd"
	if [ ! -e  RADIAL/equil_all_${i}.mdcrd ] ; then
		echo "Can't find the eq mdcrd file for ${i}"
		exit
	fi
	EQTRAJECTORYIN="RADIAL/equil_all_${i}.mdcrd"
	## echo "Found everything for ${i} and going forward."
	j=0
	while [ "$j" -lt "4" ] ; do
		if [ -e  ${OUTDIR}/EQ_All_t${i}_site-${site[${j}]}.dat ] ; then
			rm ${OUTDIR}/EQ_All_t${i}_site-${site[${j}]}.dat
		fi
		EQ_Headers="trajin RADIAL/equil_all_${i}.mdcrd" 
		EQINPUT=EQ_4Way-HOH_cpptraj_${i}_site_${site[${j}]}.in
		echo -e ${EQ_Headers} > ${EQINPUT}
		echo "# Get H-O distance info " >> ${EQINPUT}
		echo "distance H-O :${pRes[$j]}@H :${pRes[${j}]}@O out ${OUTDIR}/EQ_4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${EQINPUT}
		echo "# Get H-OG1 distance info " >> ${EQINPUT}
		echo "distance H-OG1 :${pRes[$j]}@H :${pRes[${j}]}@OG1 out ${OUTDIR}/EQ_4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${EQINPUT}
		echo "# Get H2N-O distance info " >> ${EQINPUT}
		echo "distance H2N-O :${sRes[$j]}@H2N :${pRes[${j}]}@O out ${OUTDIR}/EQ_4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${EQINPUT}
		echo "# Get H2N-OG1 distance info " >> ${EQINPUT}
		echo "distance H2N-OG1 :${sRes[$j]}@H2N :${pRes[${j}]}@OG1 out ${OUTDIR}/EQ_4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${EQINPUT}
		echo "go" >> ${EQINPUT}
	
		if [ -e  ${OUTDIR}/All_t${i}_site-${j}.dat ] ; then
			rm ${OUTDIR}/All_t${i}_site-${j}.dat
		fi
		Headers="trajin ../${i}/prod_all_fixed.crd" 
		INPUT=4Way-HOH_cpptraj_${i}_site_${site[${j}]}.in
		echo -e ${Headers} > ${INPUT}
		echo "# Get H-O distance info " >> ${INPUT}
		echo "distance H-O :${pRes[$j]}@H :${pRes[${j}]}@O out ${OUTDIR}/4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${INPUT}
		echo "# Get H-OG1 distance info " >> ${INPUT}
		echo "distance H-OG1 :${pRes[$j]}@H :${pRes[${j}]}@OG1 out ${OUTDIR}/4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${INPUT}
		echo "# Get H2N-O distance info " >> ${INPUT}
		echo "distance H2N-O :${sRes[$j]}@H2N :${pRes[${j}]}@O out ${OUTDIR}/4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${INPUT}
		echo "# Get H2N-OG1 distance info " >> ${INPUT}
		echo "distance H2N-OG1 :${sRes[$j]}@H2N :${pRes[${j}]}@OG1 out ${OUTDIR}/4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${INPUT}
		echo "go" >> ${INPUT}

		## Run the ptraj script 
		if [ "${TESTWRITE}" = "no" ] ; then
			${AMBERHOME}/bin/cpptraj ../input/${i}_SolCl.parm7 < ${EQINPUT}
		fi
		if [ "${TESTWRITE}" = "no" ] ; then
			${AMBERHOME}/bin/cpptraj ../input/Single.parm7 < ${INPUT}
		fi

#		exit

		j=$((j+1))
	done
		i=$((i+1))
done

if [ ! -e "PTRAJ_INPUTS" ] ; then
	mkdir PTRAJ_INPUTS
fi
mv *cpptraj*.in PTRAJ_INPUTS

if [ "${TESTWRITE}" = "yes" ] ; then
	exit
fi

## Remove any old concatenated files
j=0
while [ "$j" -lt "4" ] ; do
	if [ -e ${OUTDIR}/All_4Way-HOH_t00_site_${site[${j}]}.dat ] ; then
		rm ${OUTDIR}/All_4Way-HOH_t00_site_${site[${j}]}.dat
	fi
	if [ -e ${OUTDIR}/All_EQ_4Way-HOH_t00_site_${site[${j}]}.dat ] ; then
		rm ${OUTDIR}/All_EQ_4Way-HOH_t00_site_${site[${j}]}.dat
	fi
	j=$((j+1))
done
## Concatenate files
i=1
while [ "$i" -le "32" ] ; do
	j=0
	while [ "$j" -lt "4" ] ; do
		cat ${OUTDIR}/4Way-HOH-t${i}_site-${site[${j}]}.dat >> ${OUTDIR}/All_4Way-HOH_t00_site_${site[${j}]}.dat
		cat ${OUTDIR}/EQ_4Way-HOH-t${i}_site-${site[${j}]}.dat >> ${OUTDIR}/All_EQ_4Way-HOH_t00_site_${site[${j}]}.dat
		j=$((j+1))
	done
	i=$((i+1))
done
