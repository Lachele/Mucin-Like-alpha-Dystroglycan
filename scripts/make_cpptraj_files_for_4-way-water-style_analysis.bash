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

TESTWRITE="yes" # yes=only make files; no=do the runs

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
site=( "4", "5", "6", "7" )
pRes=( "4", "5", "6", "7" )
sRes=( "12", "13", "14", "15" )
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
	j=1
	while [ "$j" -le "4" ] ; do
		if [ -e  ${OUTDIR}/EQ_All_t${i}_site-${site[${j}]}.dat ] ; then
			rm ${OUTDIR}/EQ_All_t${i}_site-${site[${j}]}.dat
		fi
		EQALL=${OUTDIR}/EQ_All_t${i}_site_${site[${j}]}.dat
		EQ_Headers="trajin RADIAL/equil_all_${i}.mdcrd" 
		EQINPUT=EQ_4Way-HOH_cpptraj_${i}_site_${site[${j}]}.in
## site=( "4", "5", "6", "7" )
## pRes=( "4", "5", "6", "7" )
## sRes=( "12", "13", "14", "15" )
		echo -e ${EQ_Headers} > ${EQINPUT}
		echo "# Get H-O distance info " >> ${EQINPUT}
		echo "distance H-O :${pRes[$j]}@H :${sRes[${j}]}@O out ${OUTDIR}/EQ_4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${EQINPUT}
		echo "# Get H-OG1 distance info " >> ${EQINPUT}
		echo "distance H-OG1 :${pRes[$j]}@H :${pRes[${j}]}@OG1 out ${OUTDIR}/EQ_4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${EQINPUT}
		echo "# Get H2N-O distance info " >> ${EQINPUT}
		echo "distance H2N-O :${sRes[$j]}@H2N :${pRes[${j}]}@O out ${OUTDIR}/EQ_4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${EQINPUT}
		echo "# Get H2N-OG1 distance info " >> ${EQINPUT}
		echo "distance H2N-OG1 :${sRes[$j]}@H2N :${pRes[${j}]}@OG1 out ${OUTDIR}/EQ_4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${EQINPUT}
		echo "go" >> ${EQINPUT}
		echo "#     Num  H-O      Num  H-OG1      Num  H2N-O      Num  H2N-OG1 " > ${EQALL}
	
		if [ -e  ${OUTDIR}/All_t${i}_site-${j}.dat ] ; then
			rm ${OUTDIR}/All_t${i}_site-${j}.dat
		fi
		ALL=${OUTDIR}/All_t${i}_site-${j}.dat
		Headers="trajin ../${i}/prod_all_fixed.crd" 
		INPUT=4Way-HOH_cpptraj_${i}_site_${j}.in
		echo -e ${Headers} > ${INPUT}
		echo "# Get H-O distance info " >> ${INPUT}
		echo "distance H-O :${pRes[$j]}@H :${sRes[${j}]}@O out ${OUTDIR}/4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${INPUT}
		echo "# Get H-OG1 distance info " >> ${INPUT}
		echo "distance H-OG1 :${pRes[$j]}@H :${pRes[${j}]}@OG1 out ${OUTDIR}/4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${INPUT}
		echo "# Get H2N-O distance info " >> ${INPUT}
		echo "distance H2N-O :${sRes[$j]}@H2N :${pRes[${j}]}@O out ${OUTDIR}/4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${INPUT}
		echo "# Get H2N-OG1 distance info " >> ${INPUT}
		echo "distance H2N-OG1 :${sRes[$j]}@H2N :${pRes[${j}]}@OG1 out ${OUTDIR}/4Way-HOH-t${i}_site-${site[${j}]}.dat " >> ${INPUT}
		echo "go" >> ${INPUT}
		echo "#     Num  H-O      Num  H-OG1      Num  H2N-O      Num  H2N-OG1 " > ${ALL}

		## Run the ptraj script 
		if [ "${TESTWRITE}" = "no" ] ; then
			${AMBERHOME}/bin/cpptraj ../input/${i}_SolCl.parm7 < ${EQINPUT}
		fi
		if [ "${TESTWRITE}" = "no" ] ; then
			${AMBERHOME}/bin/cpptraj ../input/Single.parm7 < ${INPUT}
		fi

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

START HERE

## Paste and concatenate files
i=1
while [ "$i" -le "$MAXRUNS" ] ; do
	paste ${OUTDIR}/HH-4_t${i}.dat ${OUTDIR}/HH-5_t${i}.dat ${OUTDIR}/HH-6_t${i}.dat ${OUTDIR}/HH-7_t${i}.dat ${OUTDIR}/OO-4_t${i}.dat ${OUTDIR}/OO-5_t${i}.dat ${OUTDIR}/OO-6_t${i}.dat ${OUTDIR}/OO-7_t${i}.dat >> ${OUTDIR}/All_t${i}.dat
	paste ${OUTDIR}/EQ_HH-4_t${i}.dat ${OUTDIR}/EQ_HH-5_t${i}.dat ${OUTDIR}/EQ_HH-6_t${i}.dat ${OUTDIR}/EQ_HH-7_t${i}.dat ${OUTDIR}/EQ_OO-4_t${i}.dat ${OUTDIR}/EQ_OO-5_t${i}.dat ${OUTDIR}/EQ_OO-6_t${i}.dat ${OUTDIR}/EQ_OO-7_t${i}.dat >> ${OUTDIR}/EQ_All_t${i}.dat
	i=$((i+1))
done

if [ -e ${OUTDIR}/All_t00.dat ] ; then
	rm ${OUTDIR}/All_t00.dat
fi
if [ -e ${OUTDIR}/EQ_All_t00.dat ] ; then
	rm ${OUTDIR}/EQ_All_t00.dat
fi

i=1
while [ $i -le $MAXRUNS ] ; do
	cat ${OUTDIR}/All_t${i}.dat >> ${OUTDIR}/All_t00.dat
	cat ${OUTDIR}/EQ_All_t${i}.dat >> ${OUTDIR}/EQ_All_t00.dat
	i=$((i+1))
done
