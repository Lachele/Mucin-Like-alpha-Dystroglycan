#!/bin/bash

MAXNUM=32
i=1
j=1

for k in 4 5 6 7 ; do 
	echo "# J-Coupling output collected from from ${MAXNUM} runs " > HN-HA-${k}_J-Coup-tALL_Schmidt
	echo "# J-Coupling output collected from from ${MAXNUM} runs " > HA-HB-${k}_J-Coup-tALL_Schmidt
	echo "# J-Coupling output collected from from ${MAXNUM} runs " > HN-HA-${k}_J-Coup-tALL_DLIVE
done

while [ $i -le $MAXNUM ] ; do
## Run the Karplus script
	for k in 4 5 6 7 ; do 
  	perl ../../scripts/J-Couplings.pl Phi_Karplus_${k}_t${i}.dat 13 > HN-HA-${k}_t${i}_J-Coup-Out_Schmidt
  	perl ../../scripts/J-Couplings.pl Theta_Karplus_${k}_t${i}.dat 15 > HA-HB-${k}_t${i}_J-Coup-Out_Schmidt
  	perl ../../scripts/J-Couplings.pl Phi_Karplus_${k}_t${i}.dat 17 > HN-HA-${k}_t${i}_J-Coup-Out_DLIVE
	grep "Total J-Coupling:" HN-HA-${k}_t${i}_J-Coup-Out_Schmidt >> HN-HA-${k}_J-Coup-tALL_Schmidt
	grep "Total J-Coupling:" HA-HB-${k}_t${i}_J-Coup-Out_Schmidt >> HA-HB-${k}_J-Coup-tALL_Schmidt
	grep "Total J-Coupling:" HN-HA-${k}_t${i}_J-Coup-Out_DLIVE >> HN-HA-${k}_J-Coup-tALL_DLIVE
	done

	i=$((i+1))
done
