#!/bin/bash

## usage:
##	alter_pdbs.sh $1 $2
##
##	$1 is the pdb file
##	$2 is either MAN or GNC

## (ohhh we are being very lazy with the coding...)

filebase=${1%.pdb}

# remove hydrogens from lines where His the 13th or 14th character
# change CA in ACE to CH3
# change NH2 to NHE (amber name)
# substitute THR with OLT
sed '/^.\{13\}H\|^.\{12\}H/d' < $1 | sed '/ACE/s/CA /CH3/' | sed 's/NH2/NHE/' | sed 's/THR/OLT/' > ${filebase}_protein_fixed.pdb

## The following few ops should be mutually exclusive, but will use an if then
if [ "$2" = "MAN" ] ; then 
	# substitute MAN with 0MA
	# insert a blank line after each line containing O3 in 0MA
	sed 's/MAN/0MA/' < ${filebase}_protein_fixed.pdb | sed '/O3  0MA/G' > ${filebase}_sugar_fixed.pdb
elif [ "$2" = "GNC" ] ; then 
	# substitute GNC with 0VA then change names in 0VA as needed
	# insert a blank line after each line containing O6 in 0VA
	sed 's/GNC/0VA/' < ${filebase}_protein_fixed.pdb | sed '/0VA/s/NA  0VA/N2  0VA/' | sed '/0VA/s/CNA 0VA/C2N 0VA/' | sed '/0VA/s/ONA 0VA/O2N 0VA/' |  sed '/O6  0VA/G' > ${filebase}_sugar_fixed.pdb
else 
	echo "unknown sugar residue.  bailing."
	rm ${filebase}_protein_fixed.pdb
	exit
fi
##

# insert a blank line after the line containing NHE
# convert blank lines to TER cards
sed '/NHE/G' < ${filebase}_sugar_fixed.pdb | sed 's/^$/TER/' > ${filebase}_tleap.pdb

rm ${filebase}_protein_fixed.pdb ${filebase}_sugar_fixed.pdb
