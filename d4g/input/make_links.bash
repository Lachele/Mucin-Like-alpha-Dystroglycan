#!/bin/bash

MAXNUM=16

i=1

while [ $i -le $MAXNUM ] ; do 
	j=$((i+MAXNUM))
	echo "i is $i and j is $j"
	ln -s ${i}.parm7 ${j}.parm7
	ln -s ${i}.rst7 ${j}.rst7
	ln -s ${i}_SolCl.parm7 ${j}_SolCl.parm7
	ln -s ${i}_SolCl.rst7 ${j}_SolCl.rst7
	i=$((i+1))
done

#10.parm7
#10.rst7
#10_SolCl.parm7
#10_SolCl.rst7

