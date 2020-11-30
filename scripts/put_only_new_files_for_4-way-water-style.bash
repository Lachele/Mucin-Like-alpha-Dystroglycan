#!/bin/bash
###
###  Run this from TREATED/d4g
###

###
###
###  Copy up only the files resulting from the H-O-H 4-way analysis
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

# Ensure that the remote directory path exists
#    Not checking them all.  Just making sure something is there.
RESPONSE=$(ssh -o ControlPath=$SSHSOCKET lachele@frost "if [ -d 'RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g' ] ; then echo '0'; else echo '1'; fi")
if [ "${RESPONSE}" != "0" ] ; then
	echo "The remote directory appears not to exist.  Exiting."
	exit 1
fi
# Ensure that a directory called ANALYSIS exists.  If not, try to make one. 
RESPONSE=$(ssh -o ControlPath=$SSHSOCKET lachele@frost "if [ ! -d RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g/ANALYSIS ] ; then mkdir RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g/ANALYSIS; fi")
if [ "$?" != "0" ] ; then
	echo "Could not create (currently nonexistent) remote directory ANALYSIS.  Exiting."
	exit 1
fi

#ssh -S $SSHSOCKET -O exit lachele@ffrost
#exit

for i in 4WAY_HOH PTRAJ_INPUTS; do 
	RESPONSE=$(ssh -o ControlPath=$SSHSOCKET lachele@frost "if [ ! -d RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g/ANALYSIS/${i} ] ; then mkdir RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g/ANALYSIS/${i}; fi")
	if [ "$?" != "0" ] ; then
		echo "Could not create (currently nonexistent) remote directory ANALYSIS/${i}.  Exiting."
		exit 1
	fi
	scp -r -o ControlPath=$SSHSOCKET ANALYSIS/${i}/* ffrost:RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g/ANALYSIS/${i}/
done
scp -r -o ControlPath=$SSHSOCKET ANALYSIS/bin_4-way-water-style_data.bash ffrost:RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g/ANALYSIS/
scp -r -o ControlPath=$SSHSOCKET ANALYSIS/make_cpptraj_files_for_4-way-water-style_analysis.bash ffrost:RESEARCH/Mucin-Like-alpha-Dystroglycan/TREATED/d4g/ANALYSIS/
ssh -S $SSHSOCKET -O exit lachele@ffrost
