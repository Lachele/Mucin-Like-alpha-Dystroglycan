#!/bin/bash

. ../REFRESH_SETUP

MAXNUM=$NUMRUNS
i=1
j=1


if [ ! -e JCOUP ] ; then
	mkdir JCOUP
fi
for k in 4 5 6 7 ; do 
	if [ -e JCOUP/HA-HB-${k}_J-Coup-tALL_Schmidt ] ; then 
		rm JCOUP/HA-HB-${k}_J-Coup-tALL_Schmidt
	fi
	if [ -e JCOUP/HN-HA-${k}_J-Coup-tALL_Schmidt ] ; then 
		rm JCOUP/HN-HA-${k}_J-Coup-tALL_Schmidt
	fi
	if [ -e JCOUP/HN-HA-${k}_J-Coup-tALL_DLIVE ] ; then 
		rm JCOUP/HN-HA-${k}_J-Coup-tALL_DLIVE
	fi
done


while [ $i -le $MAXNUM ] ; do
## Run the Karplus script
	for k in 4 5 6 7 ; do 
  	perl ../../scripts/J-Couplings.pl ANGLES/Phi_Karplus_${k}_t${i}.dat 13 > JCOUP/HN-HA-${k}_t${i}_J-Coup-Out_Schmidt
	cat JCOUP/HN-HA-${k}_t${i}_J-Coup-Out_Schmidt >> JCOUP/HN-HA-${k}_J-Coup-tALL_Schmidt
  	perl ../../scripts/J-Couplings.pl ANGLES/Theta_Karplus_${k}_t${i}.dat 15 > JCOUP/HA-HB-${k}_t${i}_J-Coup-Out_Schmidt
	cat JCOUP/HA-HB-${k}_t${i}_J-Coup-Out_Schmidt >> JCOUP/HA-HB-${k}_J-Coup-tALL_Schmidt
  	perl ../../scripts/J-Couplings.pl ANGLES/Phi_Karplus_${k}_t${i}.dat 17 > JCOUP/HN-HA-${k}_t${i}_J-Coup-Out_DLIVE
	cat JCOUP/HN-HA-${k}_t${i}_J-Coup-Out_DLIVE >> JCOUP/HN-HA-${k}_J-Coup-tALL_DLIVE
	done

	i=$((i+1))
done
