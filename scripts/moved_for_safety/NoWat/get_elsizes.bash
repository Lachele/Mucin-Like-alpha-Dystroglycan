#!/bin/bash

##
##	This script does these things:
##
##		1.  extracts a pqr file from each initial X.rst7 
##		2.  uses that file to calculate elsize for use with alpb
##
##
##	Call me from the d4g/NoWat directory

TopDir="SIZES"
SizesOut="Sizes.txt"

if [ ! -e "${TopDir}" ] ; then
	mkdir ${TopDir}
fi

i=1
echo "Filename                 a        b        c       A_ell    A_elf    A_det" > ${TopDir}/${SizesOut}

while [ "$i" -le "32" ] ; do
	ambpdb -p ../input/Single.parm7 -pqr < ../input/${i}.rst7 > ${TopDir}/${i}.pqr
	elsize ${TopDir}/${i}.pqr  -tab  >> ${TopDir}/${SizesOut}
	i=$((i+1))
done 

## 	Some info on elsize from the documentation in the source code
##
##	There can only be one option given to elsize
##
##	options:
##	-ell leads to calculation of the exact electrostatic size, A_ell, of the effective ellipoid 
##	-abc prints the semiaxes of the effective ellipsoid  
##	-tab prints all of the above into a table
##	-hea prints table with a header.
##	-deb prints additionally some extra information. 
##
##	these options, if used at all, MUST follow the input file name. 

