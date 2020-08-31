#!/bin/bash

# This variant is only for the equilibrated water-containing bits
#	of the equilibration runs.
# This should be run from the DLIVE/d4g/ANALYSIS directory
. ../cpptraj_setup.bash

TESTWRITE="no" # yes=only make files; no=do the runs

#export AMBERHOME=/programs/amber
export AMBERHOME=/programs/amber12
PTRAJ_Headers="" # the trajin bits at the top of each file
NUMSITES=4 # The number of glycosylation sites, not that it ever changes
DATADIR="TESTBRIDGE"
PREF="TEST"
LOGFILE="${DATADIR}/${PREF}_log.txt"
## the variable typcnt accesses the following array discriminately
TYPES=("all_frames_NoWAT" "4Ways" "4Way-noBridge" "Bridge_bonds" "Bridge-no4Way")

PhiPsiLo=("Phi_3-4 :3@C :4@N :4@CA :4@C" "Phi_4-5 :4@C :5@N :5@CA :5@C" "Phi_5-6 :5@C :6@N :6@CA :6@C" "Phi_6-7 :6@C :7@N :7@CA :7@C")
PhiPsiHi=("Psi_4-5 :4@N :4@CA :4@C :5@N" "Psi_5-6 :5@N :5@CA :5@C :6@N" "Psi_6-7 :6@N :6@CA :6@C :7@N" "Psi_7-8 :7@N :7@CA :7@C :8@N")
PhiPsiSLo=("PhiS_4 :12@O5 :12@C1 :4@OG1 :4@CB" "PhiS_5 :13@O5 :13@C1 :5@OG1 :5@CB" "PhiS_6 :14@O5 :14@C1 :6@OG1 :6@CB" "PhiS_7 :15@O5 :15@C1 :7@OG1 :7@CB")
PhiPsiSHi=("PsiS_4 :12@C1 :4@OG1 :4@CB  :4@CA" "PsiS_5 :13@C1 :5@OG1 :5@CB  :5@CA" "PsiS_6 :14@C1 :6@OG1 :6@CB  :6@CA" "PsiS_7 :15@C1 :7@OG1 :7@CB  :7@CA")
KarplusLo=("Thr4_HN-N-Ca-Ha  :4@H  :4@N  :4@CA :4@HA" "Thr5_HN-N-Ca-Ha  :5@H  :5@N  :5@CA :5@HA" "Thr6_HN-N-Ca-Ha  :6@H  :6@N  :6@CA :6@HA" "Thr7_HN-N-Ca-Ha  :7@H  :7@N  :7@CA :7@HA")
KarplusHi=("Thr4_Ha-Ca-Cb-Hb :4@HA :4@CA :4@CB :4@HB" "Thr5_Ha-Ca-Cb-Hb :5@HA :5@CA :5@CB :5@HB" "Thr6_Ha-Ca-Cb-Hb :6@HA :6@CA :6@CB :6@HB" "Thr7_Ha-Ca-Cb-Hb :7@HA :7@CA :7@CB :7@HB")
OODist=("O-O :4@OG1 :4@O" "O-O :5@OG1 :5@O" "O-O :6@OG1 :6@O" "O-O :7@OG1 :7@O")
HHDist=("H-H :4@H :12@H2N" "H-H :5@H :13@H2N" "H-H :6@H :14@H2N" "H-H :7@H :15@H2N")

echo "# Starting log file on $(date)
#
# The following are the commands used to generate the ptraj/cpptraj-generated 
# coordinate analysis data in this directory.
# 
" > ${LOGFILE}

typcnt=0
for rtype in "${TYPES[@]}" ; do 
	j=0
	i=1
	while [ "$i" -le "$NUMSITES" ] ; do
echo "
#######
#######
	typcnt = ${typcnt}
#######
#######
"
		if [ "${typcnt}" -eq "0" ] ; then 
			TRAJIN="${DATADIR}/${PREF}_${rtype}.mdcrd"
			if [ ! -e ${TRAJIN} ] ; then
				echo "Can't find trajin file ${TRAJIN}"
				exit
			fi
			PTRAJ_Headers="trajin ${TRAJIN}" 
		else
			TRAJIN="${DATADIR}/${PREF}_${rtype}_${i}.mdcrd"
			if [ ! -e ${TRAJIN} ] ; then
				echo "Can't find trajin file ${TRAJIN}"
				exit
			fi
			PTRAJ_Headers="trajin ${TRAJIN}" 
		fi

		PTRAJIN="${DATADIR}/PhiPsi_${PREF}_${rtype}_${i}_cpptraj.in"
		DATAOUT="${DATADIR}/PhiPsi_${PREF}_${rtype}_${i}_cpptraj.out"
		echo "# Generate Psi and Phi for plots " > ${PTRAJIN}
		echo -e ${PTRAJ_Headers} >> ${PTRAJIN}
		echo "" >> ${PTRAJIN}
		echo "# Protein " >> ${PTRAJIN}
		echo "dihedral ${PhiPsiLo["${j}"]} out ${DATAOUT} " >> ${PTRAJIN}
		echo "dihedral ${PhiPsiHi["${j}"]} out ${DATAOUT} " >> ${PTRAJIN}
		echo "# Sugar " >> ${PTRAJIN}
		echo "dihedral ${PhiPsiSLo["${j}"]} out ${DATAOUT} " >> ${PTRAJIN}
		echo "dihedral ${PhiPsiSHi["${j}"]} out ${DATAOUT} " >> ${PTRAJIN}
		echo "" >> ${PTRAJIN}
		echo "go" >> ${PTRAJIN}
		## Run the cpptraj script 
		if [ "${TESTWRITE}" = "no" ] ; then
			if [ "${typcnt}" -lt "3" ] ; then 
			echo " ${AMBERHOME}/bin/cpptraj -i ${PTRAJIN} -p ../input/Single.parm7 " >> ${LOGFILE}
			${AMBERHOME}/bin/cpptraj -i ${PTRAJIN} -p ../input/Single.parm7
			else
			echo " ${AMBERHOME}/bin/cpptraj -i ${PTRAJIN} -p ../input/plus1water.parm7 " >> ${LOGFILE}
			${AMBERHOME}/bin/cpptraj -i ${PTRAJIN} -p ../input/plus1water.parm7
			fi
		fi
	
		PTRAJIN="${DATADIR}/Karplus_${PREF}_${rtype}_${i}_cpptraj.in"
		DATAOUT="${DATADIR}/Karplus_${PREF}_${rtype}_${i}_cpptraj.out"
		echo "# Generate angles for karplus" > ${PTRAJIN}
		echo -e ${PTRAJ_Headers} >> ${PTRAJIN}
		echo "" >> ${PTRAJIN}
		echo "dihedral ${KarplusLo["${j}"]} out ${DATAOUT} " >> ${PTRAJIN}
		echo "dihedral ${KarplusHi["${j}"]} out ${DATAOUT} " >> ${PTRAJIN}
		echo "go" >> ${PTRAJIN}
		## Run the cpptraj script 
		if [ "${TESTWRITE}" = "no" ] ; then
			if [ "${typcnt}" -lt "3" ] ; then 
			echo " ${AMBERHOME}/bin/cpptraj -i ${PTRAJIN} -p ../input/Single.parm7 " >> ${LOGFILE}
			${AMBERHOME}/bin/cpptraj -i ${PTRAJIN} -p ../input/Single.parm7
			else
			echo " ${AMBERHOME}/bin/cpptraj -i ${PTRAJIN} -p ../input/plus1water.parm7 " >> ${LOGFILE}
			${AMBERHOME}/bin/cpptraj -i ${PTRAJIN} -p ../input/plus1water.parm7
			fi
		fi

		PTRAJIN="${DATADIR}/Distance_${PREF}_${rtype}_${i}_cpptraj.in"
		DATAOUT1="${DATADIR}/Distance_H-H_${PREF}_${rtype}_${i}_cpptraj.out"
		DATAOUT2="${DATADIR}/Distance_O-O_${PREF}_${rtype}_${i}_cpptraj.out"
		echo -e ${PTRAJ_Headers} > ${PTRAJIN}
		echo "# Get H-H distance info " >> ${PTRAJIN}
		echo "distance ${HHDist["${j}"]} out ${DATAOUT1} " >> ${PTRAJIN}
		echo "# Get O-O distance info " >> ${PTRAJIN}
		echo "distance ${OODist["${j}"]} out ${DATAOUT2} " >> ${PTRAJIN}
		echo "go" >> ${PTRAJIN}
		## Run the cpptraj script 
		if [ "${TESTWRITE}" = "no" ] ; then
			if [ "${typcnt}" -lt "3" ] ; then 
			echo " ${AMBERHOME}/bin/ptraj ../input/Single.parm7 < ${PTRAJIN} " >> ${LOGFILE}
			${AMBERHOME}/bin/ptraj ../input/Single.parm7 < ${PTRAJIN}
			else
#echo " ${AMBERHOME}/bin/ptraj ../input/plus1water.parm7 < ${PTRAJIN} "
			echo " ${AMBERHOME}/bin/ptraj ../input/plus1water.parm7 < ${PTRAJIN} " >> ${LOGFILE}
			${AMBERHOME}/bin/ptraj ../input/plus1water.parm7 < ${PTRAJIN}
			fi
			# paste the distance files together for simplicity
			echo " paste ${DATAOUT1} ${DATAOUT2} > ${DATADIR}/Distance_HH+OO_${PREF}_${rtype}_${i}_cpptraj.out " >> ${LOGFILE}
			paste ${DATAOUT1} ${DATAOUT2} > ${DATADIR}/Distance_HH+OO_${PREF}_${rtype}_${i}_cpptraj.out
		fi

		i=$((i+1))
		j=$((j+1))
	done  # close loop over making ptraj input by site
	typcnt=$((typcnt+1))

done  # close loop over making ptraj input by input type


