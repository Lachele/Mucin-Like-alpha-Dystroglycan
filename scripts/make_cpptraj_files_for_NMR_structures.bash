#!/bin/bash

# This should be run from the DLIVE/${IAM}/ANALYSIS directory
. ../cpptraj_setup.bash

export AMBERHOME=/programs/amber12
TESTWRITE="no" # yes=only make files; no=do the runs

CPOUTFILENAME="PTRAJ_INPUTS/PDB_cpptraj_all.dat"
ANGLEOUTFILENAME="PDB/PDB_PhiPsi_all.dat"
RMSDOUTFILENAME="PDB/PDB_RMSD_all.dat"

# Make directories if they aren't there
if [ ! -e "PDB" ] ; then
	mkdir PDB
fi

echo "# Generate Psi and Phi for plots " > ${CPOUTFILENAME}
i=1
while [ "$i" -le "$SETSIZE" ] ; do
	echo "trajin ../input/${i}.rst7" >> ${CPOUTFILENAME}
	i=$((i+1))
done

echo "" >> ${CPOUTFILENAME}
echo "# Protein " >> ${CPOUTFILENAME}
echo "dihedral Phi_3-4 :3@C :4@N :4@CA :4@C out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral Psi_4-5 :4@N :4@CA :4@C :5@N out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral Phi_4-5 :4@C :5@N :5@CA :5@C out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral Psi_5-6 :5@N :5@CA :5@C :6@N out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral Phi_5-6 :5@C :6@N :6@CA :6@C out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral Psi_6-7 :6@N :6@CA :6@C :7@N out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral Phi_6-7 :6@C :7@N :7@CA :7@C out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral Psi_7-8 :7@N :7@CA :7@C :8@N out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}

if [ ${IAM} != "prot" ] ; then 
echo "# Sugar " >> ${CPOUTFILENAME}
echo "dihedral PhiS_4 :12@O5 :12@C1 :4@OG1 :4@CB out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral PsiS_4 :12@C1 :4@OG1 :4@CB  :4@CA out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral PhiS_5 :13@O5 :13@C1 :5@OG1 :5@CB out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral PsiS_5 :13@C1 :5@OG1 :5@CB  :5@CA out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral PhiS_6 :14@O5 :14@C1 :6@OG1 :6@CB out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral PsiS_6 :14@C1 :6@OG1 :6@CB  :6@CA out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral PhiS_7 :15@O5 :15@C1 :7@OG1 :7@CB out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "dihedral PsiS_7 :15@C1 :7@OG1 :7@CB  :7@CA out ${ANGLEOUTFILENAME} " >> ${CPOUTFILENAME}
echo "" >> ${CPOUTFILENAME}
fi

echo "# Generate RMSDs for THR backbone and for Sugar heavy atoms" >> ${CPOUTFILENAME}
echo "reference ../input/1.rst7 [ref1]" >> ${CPOUTFILENAME}
echo "rms Back :4-7&@CA,C,O,N,H out ${RMSDOUTFILENAME} ref [ref1] " >> ${CPOUTFILENAME}

if [ ${IAM} != "prot" ] ; then 
echo "rms Sugr :12-15&!@H= out ${RMSDOUTFILENAME} ref [ref1] " >> ${CPOUTFILENAME}
fi 

echo "" >> ${CPOUTFILENAME}

echo "go" >> ${CPOUTFILENAME}

## Run the cpptraj script 
if [ "${TESTWRITE}" = "no" ] ; then
	${AMBERHOME}/bin/cpptraj -i ${CPOUTFILENAME} -p ../input/Single.parm7
fi

