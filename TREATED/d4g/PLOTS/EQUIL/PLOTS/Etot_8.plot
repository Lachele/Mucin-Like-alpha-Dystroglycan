# gnuplot input file written by gather_equil_E_info.bash
set term post enh solid color
set output "Etot_8.eps"
plot "../Etot_8.dat" using 0:3:12 with yerr

