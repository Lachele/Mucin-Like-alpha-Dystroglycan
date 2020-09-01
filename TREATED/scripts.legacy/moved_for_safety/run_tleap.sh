#!/bin/bash

export AMBERHOME=$1

echo "key to run numbers and initial pdb files" > RUN_INFO

k=1

#i=../original_pdb/d4g57_close_noh_tleap.pdb
for i in $(ls ../original_pdb/*tleap.pdb) ; do 
	cp $i ./temp.pdb
	$AMBERHOME/bin/tleap -f ../../scripts/leapin
	echo "Run $k : $i" >> RUN_INFO
	mv temp1.parm7 $k.parm7
	mv temp1.rst7 $k.rst7
	mv temp2.parm7 ${k}_SolCl.parm7
	mv temp2.rst7 ${k}_SolCl.rst7
	k=$((k+1))
done

rm temp.pdb
