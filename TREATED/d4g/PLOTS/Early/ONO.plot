set term post enh solid color 14
set title "From all simulations"
unset key
set xla "Angle:  O-gly -- N -- O-back"
set yla "Normalized fraction in bin"
set output "ONO_All.eps"
plot "../GalNAc/GNC_1D_O-N-O.txt" using 1:6 with imp lw 2
