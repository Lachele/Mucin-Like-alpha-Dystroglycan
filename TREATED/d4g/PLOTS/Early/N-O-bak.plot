set term post enh solid color 14
set title "From all simulations"
unset key
se xra [2:8]
set xla "Distance:  N -- O-back"
set yla "Normalized fraction in bin"
set output "N-O-Bak.eps"
plot "../GalNAc/GNC_1D_N-O_bak.txt" using 1:6 with imp lw 2
