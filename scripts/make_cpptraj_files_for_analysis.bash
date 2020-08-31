#!/bin/bash

# This should be run from the DLIVE/${IAM}/ANALYSIS directory
. ../cpptraj_setup.bash

#export AMBERHOME=/programs/amber
export AMBERHOME=/programs/amber12
i=1
j=1
CheckForRestarts="2 3 4"  # uses variable k
PTRAJ_Headers="" # the trajin bits at the top of each file

TESTWRITE="no" # yes=only make files; no=do the runs

echo "MAXRUNS is ${MAXRUNS}"

# Make directories if they aren't there
if [ ! -e "ANGLES" ] ; then
	mkdir ANGLES
fi
if [ ! -e "DIST" ] ; then
	mkdir DIST
fi
if [ ! -e "HBOND" ] ; then
	mkdir HBOND
fi
if [ ! -e "RMSD" ] ; then
	mkdir RMSD
fi

while [ "$i" -le "$MAXRUNS" ] ; do
	echo "checking for ../${i}/"
	if [ ! -d "../${i}/" ] ; then
		i=$((i+1))
		continue
	fi
	echo "Found ../${i}/ and going forward."
	PTRAJ_Headers="trajin ../${i}/prod_all_fixed.crd" 

	echo "# Generate Psi and Phi for plots " > PhiPsi_cpptraj_${i}.in 
	echo -e ${PTRAJ_Headers} >> PhiPsi_cpptraj_${i}.in
	echo "" >> PhiPsi_cpptraj_${i}.in 
	echo "# Protein " >> PhiPsi_cpptraj_${i}.in 
	echo "dihedral Phi_3-4 :3@C :4@N :4@CA :4@C out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in 
	echo "dihedral Psi_4-5 :4@N :4@CA :4@C :5@N out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral Phi_4-5 :4@C :5@N :5@CA :5@C out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral Psi_5-6 :5@N :5@CA :5@C :6@N out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral Phi_5-6 :5@C :6@N :6@CA :6@C out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral Psi_6-7 :6@N :6@CA :6@C :7@N out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral Phi_6-7 :6@C :7@N :7@CA :7@C out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral Psi_7-8 :7@N :7@CA :7@C :8@N out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
    if [ "${IAM}" != "prot" ] ; then 
	echo "# Sugar " >> PhiPsi_cpptraj_${i}.in 
	echo "dihedral PhiS_4 :12@O5 :12@C1 :4@OG1 :4@CB out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral PsiS_4 :12@C1 :4@OG1 :4@CB  :4@CA out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral PhiS_5 :13@O5 :13@C1 :5@OG1 :5@CB out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral PsiS_5 :13@C1 :5@OG1 :5@CB  :5@CA out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral PhiS_6 :14@O5 :14@C1 :6@OG1 :6@CB out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral PsiS_6 :14@C1 :6@OG1 :6@CB  :6@CA out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral PhiS_7 :15@O5 :15@C1 :7@OG1 :7@CB out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "dihedral PsiS_7 :15@C1 :7@OG1 :7@CB  :7@CA out ANGLES/PhiPsi_t${i}.dat " >> PhiPsi_cpptraj_${i}.in
	echo "" >> PhiPsi_cpptraj_${i}.in 
   fi
	echo "go" >> PhiPsi_cpptraj_${i}.in 
	## Run the cpptraj script 
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/cpptraj -i PhiPsi_cpptraj_${i}.in -p ../input/Single.parm7
fi

	echo "# Generate angles for karplus" > Karplus_cpptraj_${i}.in 
	echo -e ${PTRAJ_Headers} >> Karplus_cpptraj_${i}.in
	echo "" >> Karplus_cpptraj_${i}.in 
	echo "dihedral Thr4_HN-N-Ca-Ha  :4@H  :4@N  :4@CA :4@HA out ANGLES/Phi_Karplus_4_t${i}.dat " >> Karplus_cpptraj_${i}.in
	echo "dihedral Thr4_Ha-Ca-Cb-Hb :4@HA :4@CA :4@CB :4@HB out ANGLES/Theta_Karplus_4_t${i}.dat " >> Karplus_cpptraj_${i}.in
	echo "dihedral Thr5_HN-N-Ca-Ha  :5@H  :5@N  :5@CA :5@HA out ANGLES/Phi_Karplus_5_t${i}.dat " >> Karplus_cpptraj_${i}.in
	echo "dihedral Thr5_Ha-Ca-Cb-Hb :5@HA :5@CA :5@CB :5@HB out ANGLES/Theta_Karplus_5_t${i}.dat " >> Karplus_cpptraj_${i}.in
	echo "dihedral Thr6_HN-N-Ca-Ha  :6@H  :6@N  :6@CA :6@HA out ANGLES/Phi_Karplus_6_t${i}.dat " >> Karplus_cpptraj_${i}.in
	echo "dihedral Thr6_Ha-Ca-Cb-Hb :6@HA :6@CA :6@CB :6@HB out ANGLES/Theta_Karplus_6_t${i}.dat " >> Karplus_cpptraj_${i}.in
	echo "dihedral Thr7_HN-N-Ca-Ha  :7@H  :7@N  :7@CA :7@HA out ANGLES/Phi_Karplus_7_t${i}.dat " >> Karplus_cpptraj_${i}.in
	echo "dihedral Thr7_Ha-Ca-Cb-Hb :7@HA :7@CA :7@CB :7@HB out ANGLES/Theta_Karplus_7_t${i}.dat " >> Karplus_cpptraj_${i}.in
	echo "go" >> Karplus_cpptraj_${i}.in 

	## Run the cpptraj script 
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/cpptraj -i Karplus_cpptraj_${i}.in -p ../input/Single.parm7
fi

	echo -e ${PTRAJ_Headers} > Distance_cpptraj_${i}.in
	echo "# Get N-N distance info " >> Distance_cpptraj_${i}.in 
	echo "distance N-N :4@N :8@N out DIST/Distances_N-N_t${i}.dat " >> Distance_cpptraj_${i}.in 
	echo "# Get End-End distance info " >> Distance_cpptraj_${i}.in 
	echo "distance EndsLYS :1@CH3 :9@NZ out DIST/Distances_EndsLYS_t${i}.dat " >> Distance_cpptraj_${i}.in 
	echo "distance EndsNHE :1@CH3 :11@N out DIST/Distances_EndsNHE_t${i}.dat " >> Distance_cpptraj_${i}.in 
	echo "go" >> Distance_cpptraj_${i}.in 

	## Run the ptraj script 
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/ptraj ../input/Single.parm7 < Distance_cpptraj_${i}.in 
fi

	echo -e ${PTRAJ_Headers} > Hbond_cpptraj_${i}.in
	echo "# Generate H-bond info " >> Hbond_cpptraj_${i}.in
	echo "hbond hbonds out HBOND/HBONDS_t${i}.dat angle 100 dist 3.0 avgout HBOND/HBONDS-Avg_t${i}.dat" >> Hbond_cpptraj_${i}.in
	echo "go" >> Hbond_cpptraj_${i}.in

	## Run the cpptraj script 
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/cpptraj -i Hbond_cpptraj_${i}.in -p ../input/Single.parm7
fi

	echo "# Generate RMSDs for THR backbone and for Sugar heavy atoms" > RMSD_cpptraj_${i}.in 
	echo -e ${PTRAJ_Headers} >> RMSD_cpptraj_${i}.in
	while [ "$j" -le "$MAXRUNS" ] ; do 
		echo "reference ../input/${j}.rst7 [ref${j}]" >> RMSD_cpptraj_${i}.in
		echo "rms Back_${j} :4-7&@CA,C,O,N,H out RMSD/Back_rmsd_t${i}_r-all.dat ref [ref${j}] " >> RMSD_cpptraj_${i}.in
            if [ "${IAM}" != "prot" ] ; then 
		echo "rms Sugr_${j} :12-15&!@H= out RMSD/Sugr_rmsd_t${i}_r-all.dat ref [ref${j}] " >> RMSD_cpptraj_${i}.in
            fi
		echo "" >> RMSD_cpptraj_${i}.in 
		j=$((j+1))
	done 
	echo "go" >> RMSD_cpptraj_${i}.in
	
	## Run the cpptraj script 
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/cpptraj -i RMSD_cpptraj_${i}.in -p ../input/Single.parm7
fi

	i=$((i+1))
	j=1
done

mv *cpptraj*.in PTRAJ_INPUTS

exit




if [ "${TESTWRITE}" = "no" ] ; then
## Concatenate all the PhiPsi and RMSD files
if [ -e ANGLES/Phi-Psi_All_t00.dat ] ; then
	rm ANGLES/Phi-Psi_All_t00.dat
fi
if [ -e RMSD/Back_rmsd_All_t00.dat ] ; then
	rm RMSD/Back_rmsd_ALL_t00.dat
fi
if [ -e RMSD/Sugr_rmsd_All_t00.dat ] ; then
	rm RMSD/Sugr_rmsd_ALL_t00.dat
fi
i=1
while [ $i -le $MAXRUNS ] ; do
	cat ANGLES/PhiPsi_t${i}.dat >> ANGLES/Phi-Psi_All_t00.dat
	cat RMSD/Back_rmsd_t${i}.dat >> RMSD/Back_rmsd_All_t00.dat
	cat RMSD/Sugr_rmsd_t${i}.dat >> RMSD/Sugr_rmsd_All_t00.dat
	echo "" >> RMSD/Back_rmsd_All_t00.dat
	echo "" >> RMSD/Sugr_rmsd_All_t00.dat
	i=$((i+1))
done
fi
