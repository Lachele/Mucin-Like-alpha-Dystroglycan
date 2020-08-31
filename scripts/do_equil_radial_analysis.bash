#!/bin/bash

###
###   This script is only for the GalNAc runs.  
###      
###      It makes new traj files for all equil.crd's after 100 frames.
###      Then, it does radial distribution analyses on each.
###
###      Call me from d4g/ANALYSIS 
###
###

export AMBERHOME="/programs/amber12"
CPPTRAJ="${AMBERHOME}/bin/cpptraj -i"
NUMRUNS=32
#NUMRUNS=1
BINSZ="0.1"
MAXBIN="10"


if [ ! -d RADIAL ] ; then 
	mkdir RADIAL
fi
i=1
while [ $i -le $NUMRUNS ] ; do
	INFILE="NULL"
	if [ -e /e05/lachele/Eliot/DLIVE/d4g/${i}/equil.nc ] ; then 
		mv /e05/lachele/Eliot/DLIVE/d4g/${i}/equil.nc /e05/lachele/Eliot/DLIVE/d4g/${i}/equil.crd
	fi
	if [ ! -e /e05/lachele/Eliot/DLIVE/d4g/${i}/equil.crd ] ; then 
		echo "Cannot find input file: /e05/lachele/Eliot/DLIVE/d4g/${i}/equil.crd.  Exiting."
		exit
	fi
	PTRAJFILE="RADIAL/cpptraj_radial_${i}.in"
	echo "# cpptraj input file made by do_equil_radial_analysis.bash" > ${PTRAJFILE}

	echo "parm ../input/${i}_SolCl.parm7" >> ${PTRAJFILE}
	echo "trajin /e05/lachele/Eliot/DLIVE/d4g/${i}/equil.crd 100 " >> ${PTRAJFILE}

	echo "radial RADIAL/GalNAc_1_N2_${i}.dat ${BINSZ} ${MAXBIN} :12@N2 :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/GalNAc_1_H2N_${i}.dat ${BINSZ} ${MAXBIN} :12@H2N :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_1_O_${i}.dat ${BINSZ} ${MAXBIN} :4@O :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_1_N_${i}.dat ${BINSZ} ${MAXBIN} :4@N :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_1_H_${i}.dat ${BINSZ} ${MAXBIN} :4@H :WAT@O" >> ${PTRAJFILE}
	
	echo "radial RADIAL/GalNAc_2_N2_${i}.dat ${BINSZ} ${MAXBIN} :13@N2 :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/GalNAc_2_H2N_${i}.dat ${BINSZ} ${MAXBIN} :13@H2N :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_2_O_${i}.dat ${BINSZ} ${MAXBIN} :5@O :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_2_N_${i}.dat ${BINSZ} ${MAXBIN} :5@N :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_2_H_${i}.dat ${BINSZ} ${MAXBIN} :5@H :WAT@O" >> ${PTRAJFILE}
	
	echo "radial RADIAL/GalNAc_3_N2_${i}.dat ${BINSZ} ${MAXBIN} :14@N2 :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/GalNAc_3_H2N_${i}.dat ${BINSZ} ${MAXBIN} :14@H2N :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_3_O_${i}.dat ${BINSZ} ${MAXBIN} :6@O :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_3_N_${i}.dat ${BINSZ} ${MAXBIN} :6@N :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_3_H_${i}.dat ${BINSZ} ${MAXBIN} :6@H :WAT@O" >> ${PTRAJFILE}
	
	echo "radial RADIAL/GalNAc_4_N2_${i}.dat ${BINSZ} ${MAXBIN} :15@N2 :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/GalNAc_4_H2N_${i}.dat ${BINSZ} ${MAXBIN} :15@H2N :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_4_O_${i}.dat ${BINSZ} ${MAXBIN} :7@O :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_4_N_${i}.dat ${BINSZ} ${MAXBIN} :7@N :WAT@O" >> ${PTRAJFILE}
	echo "radial RADIAL/THR_4_H_${i}.dat ${BINSZ} ${MAXBIN} :7@H :WAT@O" >> ${PTRAJFILE}
	
	echo "trajout RADIAL/equil_all_${i}.mdcrd" >> ${PTRAJFILE}
	
	echo "go" >> ${PTRAJFILE}

	${CPPTRAJ}  ${PTRAJFILE}

	i=$((i+1))
done

