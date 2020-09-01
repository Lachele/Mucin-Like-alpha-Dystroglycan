set term post enh solid color 
set output "Phi-Psi_S_All_t00.ps"
set multiplot
load "../../scripts/S4"
reset
load "../../scripts/S5"
reset
load "../../scripts/S6"
reset
load "../../scripts/S7"
unset multiplot
