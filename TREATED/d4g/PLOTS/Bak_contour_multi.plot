reset
set term post enh solid color 12
set output "Bak_contour_multi.eps"
set multiplot

load "Bak_contour_1.plot"
load "Bak_contour_2.plot"
load "Bak_contour_3.plot"
load "Bak_contour_4.plot"

unset multiplot
