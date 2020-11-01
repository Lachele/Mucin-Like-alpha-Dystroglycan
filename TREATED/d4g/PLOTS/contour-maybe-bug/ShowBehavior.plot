set parametric
set contour base
set view 0,0,1
unset surface
set dgrid3d
set cntrparam linear

#set cntrparam levels discrete 0.14,0.12,0.10,0.08,0.075,0.07,0.065,0.060,0.055,0.05,0.045,0.04,0.03,0.02,0.01
set cntrparam levels discrete 0.12,0.10,0.09,0.08,0.075,0.07,0.065,0.060,0.055,0.05,0.045,0.04

## these show there is no finding that maximum:
#set cntrparam levels discrete 0.12,0.10,0.09,0.089,0.088,0.087,0.086,0.085,0.084,0.083,0.082,0.081,0.08,0.079,0.078,0.077,0.076,0.075,0.074,0.073,0.072,0.07

set table "contours.txt"
splot "P_CONT_1" using 1:2:4 with lines
unset table
#
#plot \
     "P_CONT_1" using 1:2, \
     "contours.txt" i 11 w l lw 2 ti "0.080",\
     "contours.txt" i 10 w l lw 2 ti "0.075",\
     "contours.txt" i 9 w l lw 2 ti "0.070",\
     "contours.txt" i 8 w l lw 2 ti "0.065",\
     "contours.txt" i 7 w l lw 2 ti "0.060",\
     "contours.txt" i 6 w l lw 2 ti "0.055",\
     "contours.txt" i 5 w l lw 2 ti "0.050",\
     "contours.txt" i 4 w l lw 2 ti "0.045",\
     "contours.txt" i 3 w l lw 2 ti "0.040" 

