#!/bin/bash

for site in 4 5 6 7 ; do 
	for phase in All All_EQ ; do 
		for oxygen in O OG1 ; do
			Gnuplot_File_Prefix=${phase}_site-${site}_${oxygen}
			convert ${Gnuplot_File_Prefix}.ps ${Gnuplot_File_Prefix}.png
		done
	done
done

