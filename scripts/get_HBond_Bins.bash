#!/bin/bash
if [ $# -lt 1 ] ; then
	echo "need number of hbonds on the command line"
	exit
fi

../../scripts/src/hbond_analysis/makeHbondBins $1
