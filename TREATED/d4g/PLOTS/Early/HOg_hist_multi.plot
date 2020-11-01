set term post enh solid color 10
set output "HOg_hist_multi.eps"
set multiplot

reset
set size 0.5,0.5
set origin 0,0.5
set title "GalNAc 1 Normalized fraction over all simulations"
set key top right
set xla "Distance: H -- O-back"
set yla "Fraction"
plot "../GalNAc/GNC_1D_H-O_gly.txt" using 1:2 with imp lw 2

reset
set size 0.5,0.5
set origin 0.5,0.5
set title "GalNAc 2 Normalized fraction over all simulations"
set key top right
set xla "Distance: H -- O-back"
set yla "Fraction"
plot "../GalNAc/GNC_1D_H-O_gly.txt" using 1:3 with imp lw 2

reset
set size 0.5,0.5
set origin 0,0
set title "GalNAc 3 Normalized fraction over all simulations"
set key top right
set xla "Distance: H -- O-back"
set yla "Fraction"
plot "../GalNAc/GNC_1D_H-O_gly.txt" using 1:4 with imp lw 2

reset
set size 0.5,0.5
set origin 0.5,0
set title "GalNAc 4 Normalized fraction over all simulations"
set key top right
set xla "Distance: H -- O-back"
set yla "Fraction"
plot "../GalNAc/GNC_1D_H-O_gly.txt" using 1:5 with imp lw 2

unset multiplot

reset
set term post enh solid color 10
set output "HOg_hist_all.eps"
set title "Normalized fraction over all simulations, all four GalNAc's"
set key top right
set xla "Distance: H -- O-back"
set yla "Fraction"
plot "../GalNAc/GNC_1D_H-O_gly.txt" using 1:6 with imp lw 2

