#!/bin/bash
###
###  Run this from TREATED/d4g
###

###
###
###  Retrieve only the files needed to run the H-O-H 4-way analysis
###
###

# Open a socket to frost
SSHSOCKET=~/.ssh/lachele@ffrost
ssh -M -f -N -o ControlPath=$SSHSOCKET lachele@ffrost
# Check that the socket is working; fail if not
RESPONSE=$(ssh -o ControlPath=$SSHSOCKET lachele@ffrost "echo '0'")
if [ "${RESPONSE}" != "0" ] ; then
	echo "Got '${RESPONSE}' instead of '0'.  Exiting"
	exit 1
fi

# Ensure directory for the input equilibration data exists
if [ ! -d "ANALYSIS/RADIAL" ] ; then
	mkdir -p "ANALYSIS/RADIAL"
fi

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 ; do 
	if [ ! -d "${i}" ] ; then
		mkdir ${i}
	fi
	scp -r -o ControlPath=$SSHSOCKET ffrost:RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g/${i}/prod_all_fixed.crd ${i}
	scp -r -o ControlPath=$SSHSOCKET ffrost:RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g/ANALYSIS/RADIAL/equil_all_${i}.mdcrd  ANALYSIS/RADIAL/equil_all_${i}.mdcrd
done
ssh -S $SSHSOCKET -O exit lachele@ffrost
