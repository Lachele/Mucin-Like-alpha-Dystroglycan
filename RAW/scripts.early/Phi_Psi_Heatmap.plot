#!/usr/bin/gnuplot -persist
#
#    
#    	G N U P L O T
#    	Version 4.4 patchlevel 3
#    	last modified March 2011
#    	System: Linux 3.2.0-29-generic
#    
#    	Copyright (C) 1986-1993, 1998, 2004, 2007-2010
#    	Thomas Williams, Colin Kelley and many others
#    
#    	gnuplot home:     http://www.gnuplot.info
#    	faq, bugs, etc:   type "help seeking-assistance"
#    	immediate help:   type "help"
#    	plot window:      hit 'h'
# set terminal wxt 0
# set output
reset
unset key
set title "" 
#set size 0.5,0.5
set size square
set xlabel "Phi" 
set ylabel "Psi" 
set cblabel "Counts" 
set cbrange [ 0.00000 : 3000.0 ] noreverse nowriteback
set palette rgbformulae 2, -3, -3   ## linear in white
#set palette rgbformulae 2, -4, -4  ## x**2 in white
#set palette rgbformulae 2, -5, -5  ## x**3 in white
#set palette rgbformulae 2, -6, -6  ## x**4 in white
set xra [0:36]
set yra [0:36]
set grid xtics front 
set grid ytics front 
set grid mxtics front 
set grid mytics front 
set xtics ("-180" 0, "-120" 6, "-60" 12, "0" 18, "60" 24, "120" 30, "180" 36)
set ytics ("-180" 0, "-120" 6, "-60" 12, "0" 18, "60" 24, "120" 30, "180" 36)
#splot "testmatrix2.dat" matrix with image
#splot "matrix.dat" matrix with image
plot "BINS_1_00" matrix with image 
#    EOF
