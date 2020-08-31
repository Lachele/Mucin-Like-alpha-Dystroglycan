#!/bin/bash

if [ "$1" = "" ] ; then
	echo "Add d4m, d4g or prot after script name"
	exit
fi
if [ "$1" = "d4g" ] ; then
	./get_J_points 32 1 8.68 8.70
	./get_J_points 32 2 9.51 9.71
	./get_J_points 32 3 9.42 9.62
	./get_J_points 32 4 9.24 9.26
elif [ "$1" = "d4m" ] ; then
	./get_J_points 36 1 8.33 8.35
	./get_J_points 36 2 8.41 8.43
	./get_J_points 36 3 8.32 8.34
	./get_J_points 36 4 8.05 8.07
elif [ "$1" = "prot" ] ; then
	./get_J_points 48 1 7.58 7.60
	./get_J_points 48 2 7.77 7.79
	./get_J_points 48 3 7.59 7.61
	./get_J_points 48 4 7.49 7.51
else
	echo "Cannot find matching set"
fi
