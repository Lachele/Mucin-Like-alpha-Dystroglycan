#!/bin/bash

## Call me from:
## d4g/ANALYSIS/WAT_BOND

MAXRUNS=32
i=1

while [ $i -le $MAXRUNS ] ; do 

	grep -c  "   $i   " test_Bridge_bonds_1.dat >> Num_bridge_per_sim_1.dat
	grep -c  "   $i   " test_Bridge_bonds_2.dat >> Num_bridge_per_sim_2.dat
	grep -c  "   $i   " test_Bridge_bonds_3.dat >> Num_bridge_per_sim_3.dat
	grep -c  "   $i   " test_Bridge_bonds_4.dat >> Num_bridge_per_sim_4.dat
	i=$((i+1))
done 
