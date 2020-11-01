set term post enh solid color 14
set title "From all simulations"
unset key
se xra [5:11]
set xla "Distance:  N -- O-back + N -- O-gly"
set yla "Normalized fraction in bin"
set output "SumAll.eps"
plot "../GalNAc/GNC_1D_N-O_SUM.txt" using 1:6 with imp lw 2
