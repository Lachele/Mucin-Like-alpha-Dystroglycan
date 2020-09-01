#!/bin/bash

##  $1 needs to be MAN or GNC
## call from rundir/input where there is a rundir/original_pdb contaiing
## pdb's to reformat for tleap

if [ -d ../original_pdb ] ; then
	rm -f ../original_pdb/*_tleap.pdb
fi

for i in $(ls ../original_pdb/*.pdb) ; do 
	bash ../../scripts/alter_pdbs.sh $i $1
done

