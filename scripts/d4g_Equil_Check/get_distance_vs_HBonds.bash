#!/bin/bash
. ../cpptraj_setup.bash
rn=1

cd HBOND
if [ -e "cut.tmp" ] ; then
	rm cut.tmp
fi
while [ $rn -le $MAXRUNS ] ; do
	tr -s ' ' < HBONDS-Avg_t${rn}.dat > tr.tmp
	cut -d ' ' -f 1,2,3 < tr.tmp >> cut.tmp 
	rn=$((rn+1))
done

sort < cut.tmp > sort.tmp
uniq < sort.tmp > UNIQUE_HBONDS.txt

rm tr.tmp cut.tmp sort.tmp

../../../scripts/src/hbond_analysis/hbond_analysis UNIQUE_HBONDS.txt LENGTH_DETAILS $MAXRUNS
