#!/bin/bash

MAXNUM=32
i=1
j=1

export AMBERHOME=/programs/amber12

while [ $i -le $MAXNUM ] ; do

## Fix the number of atoms in the prod.nc file
	echo "trajin ../${i}/prod.nc  [traj${i}] " > all_cpptraj_${i}p.in 
	echo "" >> all_cpptraj_${i}p.in 
	echo "strip :WAT " >> all_cpptraj_${i}p.in
	echo "trajout ../${i}/prods.nc netcdf " >> all_cpptraj_${i}p.in
	echo "go" >>all_cpptraj_${i}p.in


## Generate the cpptraj input script
	echo "trajin ../${i}/prods.nc  [traj${i}] " > all_cpptraj_${i}.in 
	echo "" >> all_cpptraj_${i}.in 

	echo "# Generate Psi and Phi for plots " >> all_cpptraj_${i}.in 
	echo "" >> all_cpptraj_${i}.in 
	echo "# Protein " >> all_cpptraj_${i}.in 
	echo "dihedral Phi_3-4 :3@C :4@N :4@CA :4@C out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in 
	echo "dihedral Psi_4-5 :4@N :4@CA :4@C :5@N out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Phi_4-5 :4@C :5@N :5@CA :5@C out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Psi_5-6 :5@N :5@CA :5@C :6@N out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Phi_5-6 :5@C :6@N :6@CA :6@C out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Psi_6-7 :6@N :6@CA :6@C :7@N out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Phi_6-7 :6@C :7@N :7@CA :7@C out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Psi_7-8 :7@N :7@CA :7@C :8@N out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "# Sugar " >> all_cpptraj_${i}.in 
	echo "dihedral PhiS_4 :12@O5 :12@C1 :4@OG1 :4@CB out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral PsiS_4 :12@C1 :4@OG1 :4@CB :4@CA out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral PhiS_5 :13@O5 :13@C1 :5@OG1 :5@CB out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral PsiS_5 :13@C1 :5@OG1 :5@CB :5@CA out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral PhiS_6 :14@O5 :14@C1 :6@OG1 :6@CB out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral PsiS_6 :14@C1 :6@OG1 :6@CB :6@CA out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral PhiS_7 :15@O5 :15@C1 :7@OG1 :7@CB out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral PsiS_7 :15@C1 :7@OG1 :7@CB :7@CA out PhiPsi_prod_rmsd_t${i}.dat " >> all_cpptraj_${i}.in
	echo "" >> all_cpptraj_${i}.in 

	echo "# Generate angles for karplus" >> all_cpptraj_${i}.in 
	echo "" >> all_cpptraj_${i}.in 
	echo "dihedral Thr4_HN-N-Ca-Ha :4@H :4@N :4@CA :4@HA out Phi_Karplus_4_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Thr4_Ha-Ca-Cb-Hb :4@HA :4@CA :4@CB :4@HB out Theta_Karplus_4_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Thr5_HN-N-Ca-Ha :5@H :5@N :5@CA :5@HA out Phi_Karplus_5_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Thr5_Ha-Ca-Cb-Hb :5@HA :5@CA :5@CB :5@HB out Theta_Karplus_5_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Thr6_HN-N-Ca-Ha :6@H :6@N :6@CA :6@HA out Phi_Karplus_6_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Thr6_Ha-Ca-Cb-Hb :6@HA :6@CA :6@CB :6@HB out Theta_Karplus_6_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Thr7_HN-N-Ca-Ha :7@H :7@N :7@CA :7@HA out Phi_Karplus_7_t${i}.dat " >> all_cpptraj_${i}.in
	echo "dihedral Thr7_Ha-Ca-Cb-Hb :7@HA :7@CA :7@CB :7@HB out Theta_Karplus_7_t${i}.dat " >> all_cpptraj_${i}.in
	echo "" >> all_cpptraj_${i}.in 

	echo "# Generate RMSDs for THR backbone and for Sugar heavy atoms" >> all_cpptraj_${i}.in 
	echo "" >> all_cpptraj_${i}.in 
	while [ $j -le $MAXNUM ] ; do 
		echo "reference ../input/${j}.rst7 [ref${j}]" >> all_cpptraj_${i}.in
		echo "rms Back_${j} :4-7&@CA,C,O,N,H out Back_prod_rmsd_t${i}_r-all.dat ref [ref${j}] " >> all_cpptraj_${i}.in
		echo "rms Sugr_${j} :12-15&!@H= out Sugr_prod_rmsd_t${i}_r-all.dat ref [ref${j}] " >> all_cpptraj_${i}.in
		echo "" >> all_cpptraj_${i}.in 
		j=$((j+1))
	done 
	echo "go" >> all_cpptraj_${i}.in

## Run the cpptraj script
	${AMBERHOME}/bin/cpptraj -i all_cpptraj_${i}p.in -p ../input/plus8water.parm7
	${AMBERHOME}/bin/cpptraj -i all_cpptraj_${i}.in -p ../input/Single.parm7

	i=$((i+1))
	j=1
done

## Concatenate all the PhiPsi files
if [ -e Phi-Psi_All_t00.dat ] ; then
	rm Phi-Psi_All_t00.dat
fi
i=1
while [ $i -le $MAXNUM ] ; do
	cat PhiPsi_prod_rmsd_t${i}.dat >> Phi-Psi_All_t00.dat
	i=$((i+1))
done
