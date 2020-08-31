#!/bin/bash

echo "#Starting timings on $(date) for $(pwd) " > TIMINGS.dat

if [ -d "d4g" ] ; then 
	echo "found directory d4g"
	cd d4g 
	echo "# d4g " >> ../TIMINGS.dat 
	grep -A2 "Average timings for all steps" */prod*.info | grep "ns/day"  >> ../TIMINGS.dat
fi

echo "" >> TIMINGS.dat

if [ -d "../d4m" ] ; then 
	echo "found directory ../d4m"
	cd ../d4m 
	echo "# d4m " >> ../TIMINGS.dat
	grep -A2 "Average timings for all steps" */prod*.info | grep "ns/day"  >> ../TIMINGS.dat
fi

echo "" >> TIMINGS.dat

if [ -d "../protein" ] ; then 
	echo "found directory ../protein"
	cd ../protein 
	echo "# protein " >> ../TIMINGS.dat
	grep -A2 "Average timings for all steps" */prod*.info | grep "ns/day"  >> ../TIMINGS.dat
fi
