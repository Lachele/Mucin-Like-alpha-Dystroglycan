#!/bin/bash

## usage:
##	alter_pdbs.sh $1 
##
##	$1 is the pdb file

## (ohhh we are being very lazy with the coding...)

filebase=${1%.pdb}

# remove hydrogens from lines where His the 13th or 14th character
# change CA in ACE to CH3
# change NH2 to NHE (amber name)
sed '/^.\{13\}H\|^.\{12\}H/d' < $1 | sed '/ACE/s/CA /CH3/' | sed 's/NH2/NHE/'  > ${filebase}_tleap.pdb

