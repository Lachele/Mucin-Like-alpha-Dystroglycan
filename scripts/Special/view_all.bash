#!/bin/bash

#
#  This was created for, and run within d4g/original_pdb
#
#	It could be repurposed for another set if need be.
#	It's purpose is to rapidly view the automatically-generated
#	tleap versions of the pdb files as a check for sanity. 
#	
#	Requires: load_two.vmd to exist in d4g/original_pdb
#		- in practice that file, and the script, are symlinks
#


for i in fn1 fn2 fn3 fn4 fn5 fn6 fn7 d4g57_close_noh fn9 fn10 fn11 fn12 fn13 fn14 fn15 fn16 ; do 
	cp ${i}.pdb temp1.pdb
	cp ${i}_tleap.pdb temp2.pdb
echo "
================================================================

	Doing ${i} 

================================================================
"
	read ok
	vmd -e load_two.vmd
	rm temp1.pdb temp2.pdb
done
