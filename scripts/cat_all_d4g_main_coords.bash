#!/bin/bash

echo "Concatenated trajectory for special purpose" > d4g_ALL_FRAMES.mdcrd

i=1
while [ "$i" -le "32" ] ; do
        frames=$(wc -l ../${i}/prod_all_fixed.crd | cut -d ' ' -f1)
#echo "Frames is ${frames}"
        frames=$((frames-1))
        tail -n ${frames} ../${i}/prod_all_fixed.crd >> d4g_ALL_FRAMES.mdcrd
#echo "    and is now $frames"
        i=$((i+1))
done

