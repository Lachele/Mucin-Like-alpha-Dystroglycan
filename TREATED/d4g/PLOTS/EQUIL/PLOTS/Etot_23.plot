# gnuplot input file written by gather_equil_E_info.bash
set term post enh solid color
set output "Etot_23.eps"
plot "../Etot_23.dat" using 0:3:12 with yerr

