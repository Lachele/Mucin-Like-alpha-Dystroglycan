#!/bin/bash
outfile="label_tails.dat"
echo "# tails from etot equil files for making labels" > ${outfile}
i=1
while [ "$i" -le "32" ] ; do
	line="$(tail -1 Etot_${i}.dat)"
	line="${i} ${line}"
	echo "${line}" >>  ${outfile}
	i=$((i+1))
done
