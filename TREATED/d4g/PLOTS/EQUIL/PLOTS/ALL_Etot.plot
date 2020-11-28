# gnuplot input file written by gather_equil_E_info.bash
reset
set term post enh solid color
set output "ALL_Etot.eps"
unset key
se xla "Frame index"
se yla "Total system energy, kcal/mol"
set style data lines
set label 1 "1, 17" at 500,-34600
set label 2 "2, 18" at 570,-34700
set label 3 "3, 19" at 500,-38600
set label 4 "4, 20" at 500,-36000
set label 5 "5, 21" at 500,-25500
set label 6 "6, 22" at 500,-31000
set label 7 "7, 23" at 500,-30000
set label 8 "8, 24" at 450,-34000
set label 9 "9, 25" at 500,-37000
set label 10 "10, 26" at 500,-41000
set label 11 "11, 27" at 500,-33000
set label 12 "12, 28" at 500,-23800
set label 13 "13, 29" at 500,-26700
set label 14 "14, 30" at 500,-29100
set label 15 "15, 31" at 500,-28300
set label 16 "16, 32" at 500,-42300
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
