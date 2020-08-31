set term post enh solid color
set output "J-Coupling_comparison.ps"
set multiplot
load "Observed.plot"
load "2D.plot"
load "Karplus.plot"
load "Schmidt.plot"
unset multiplot
