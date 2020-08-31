#!/bin/bash
if [ $# -lt 1 ] ; then
	echo "need number of hbonds on the command line"
	exit
fi

cd HBOND
i=1
while [ $i -le 9 ] ; do	
	tr -s ' ' < LENGTH_DETAILS_000${i}_HBond_details.txt > temp1
	sed '/^#.*/d' < temp1 > temp2
	cut -d ' ' -f 8 < temp2 > temp3
	sed 's/^/length = /' < temp3 > temp4
	echo $i
	../../../scripts/src/statistics/makeMDBins temp4 BOND length 100
	sed "s/$/  ${i}/" < BOND_bins.txt > BOND_${i}_bins.txt
	i=$((i+1))
done
while [ $i -le 99 ] ; do	
	tr -s ' ' < LENGTH_DETAILS_00${i}_HBond_details.txt > temp1
	sed '/^#.*/d' < temp1 > temp2
	cut -d ' ' -f 8 < temp2 > temp3
	sed 's/^/length = /' < temp3 > temp4
	echo $i
	../../../scripts/src/statistics/makeMDBins temp4 BOND length 100
	sed "s/$/  ${i}/" < BOND_bins.txt > BOND_${i}_bins.txt
	i=$((i+1))
done
while [ $i -le $1 ] ; do	
	tr -s ' ' < LENGTH_DETAILS_0${i}_HBond_details.txt > temp1
	sed '/^#.*/d' < temp1 > temp2
	cut -d ' ' -f 8 < temp2 > temp3
	sed 's/^/length = /' < temp3 > temp4
	echo $i
	../../../scripts/src/statistics/makeMDBins temp4 BOND length 100
	sed "s/$/  ${i}/" < BOND_bins.txt > BOND_${i}_bins.txt
	i=$((i+1))
done

cat BOND*bins.txt > ALL_BOND_BINS.txt

rm temp1 temp2 temp3 temp4 BOND_bins.txt
