set term post enh solid color 
set output "Phi-Psi_All_t00.ps"
set multiplot
load "../../scripts/P4"
reset
load "../../scripts/P5"
reset
load "../../scripts/P6"
reset
load "../../scripts/P7"
unset multiplot
