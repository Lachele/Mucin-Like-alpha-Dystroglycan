#!/bin/bash

## call from rundir/input where there is a rundir/original_pdb contaiing
## pdb's to reformat for tleap

if [ -d ../original_pdb ] ; then
	rm -f ../original_pdb/*_tleap.pdb
fi

for i in $(ls ../original_pdb/*.pdb) ; do 
	bash ../../scripts/protein/alter_protein_pdbs.sh $i 
done

