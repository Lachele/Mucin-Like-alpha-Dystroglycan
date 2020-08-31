#!/bin/bash

. ../cpptraj_setup.bash

##  For the initial data extraction
SCRIPTDIR="../../scripts/"
OUTDIR="2D_J-Coupling"
ListString="ANGLES/*Psi*t*dat"
ExtractEXE="${SCRIPTDIR}/src/extract_data/make_phi-psi_files"

## For the 2D J-Coupling
GRIDFILE="../${SCRIPTDIR}/src/2D_JCOUPLING/grid_x_y_J_12_14"
JCoupEXE="../${SCRIPTDIR}/src/2D_JCOUPLING/InterpolateJ"

# If not already present, generate output directory 
if [ ! -d ${OUTDIR} ] ; then 
   mkdir ${OUTDIR}
fi

# Run the data extraction program 
for i in $( ls ${ListString} ) ; do 
	echo "Extracting $i"
	${ExtractEXE} $i
done

cd ${OUTDIR} || exit

if [ -e GRID ] ; then
 	rm GRID || exit
fi
ln -s ${GRIDFILE} GRID
for pn in 1 2 3 4 ; do
	rn=1
	#echo "Interpolated Phi_Psi J-Couplings for file set ${pn}" > JOUT_${pn}_ALL
	while [ $rn -le $MAXRUNS ] ; do 
		echo "Calculating 2D J-Coupling for ${pn}_${rn}"
		if [ -e DATA ] ; then
		 	rm DATA || exit
		fi
		ln -s ${pn}_${rn} DATA  || exit
		${JCoupEXE} > JOUT_${pn}_${rn}
		cat JOUT_${pn}_${rn} >> JOUT_${pn}_ALL
		rn=$((rn+1))
	done
done
