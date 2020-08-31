#!/bin/bash

####
####  Be careful using this!  
####

. ../REFRESH_SETUP

for i in $(ls ANGLES/PhiPsi*) ; do

	mv $i ${i}_withnans
	grep -v nan ${i}_withnans > $i 

done
