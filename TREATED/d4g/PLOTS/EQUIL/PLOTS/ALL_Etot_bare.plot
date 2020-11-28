# gnuplot input file written by gather_equil_E_info.bash
reset
#set term post enh solid color
#set output "ALL_Etot.eps"
unset key
set style data lines
plot \
  "../Etot_1.dat" using 0:3,\
  "../Etot_2.dat" using 0:3,\
  "../Etot_3.dat" using 0:3,\
  "../Etot_4.dat" using 0:3,\
  "../Etot_5.dat" using 0:3,\
  "../Etot_6.dat" using 0:3,\
  "../Etot_7.dat" using 0:3,\
  "../Etot_8.dat" using 0:3,\
  "../Etot_9.dat" using 0:3,\
  "../Etot_10.dat" using 0:3,\
  "../Etot_11.dat" using 0:3,\
  "../Etot_12.dat" using 0:3,\
  "../Etot_13.dat" using 0:3,\
  "../Etot_14.dat" using 0:3,\
  "../Etot_15.dat" using 0:3,\
  "../Etot_16.dat" using 0:3,\
  "../Etot_17.dat" using 0:3,\
  "../Etot_18.dat" using 0:3,\
  "../Etot_19.dat" using 0:3,\
  "../Etot_20.dat" using 0:3,\
  "../Etot_21.dat" using 0:3,\
  "../Etot_22.dat" using 0:3,\
  "../Etot_23.dat" using 0:3,\
  "../Etot_24.dat" using 0:3,\
  "../Etot_25.dat" using 0:3,\
  "../Etot_26.dat" using 0:3,\
  "../Etot_27.dat" using 0:3,\
  "../Etot_28.dat" using 0:3,\
  "../Etot_29.dat" using 0:3,\
  "../Etot_30.dat" using 0:3,\
  "../Etot_31.dat" using 0:3,\
  "../Etot_32.dat" using 0:3

#  "../Etot_2.dat" using 0:($3-300),\
#  "../Etot_3.dat" using 0:($3-300),\
