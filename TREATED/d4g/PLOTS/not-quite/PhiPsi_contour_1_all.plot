set parametric
set contour base
set view 0,0,1
unset surface
set dgrid3d
set cntrparam cubicspline

### each one needs its own set of labels, I think...
##
## these aren't so good
## set cntrparam levels discrete 0.14,0.12,0.1,0.08,0.075,0.07,0.06,0.065,0.05,0.045,0.04
##
## these are ok
#set cntrparam levels discrete 0.14,0.12,0.1,0.08,0.075,0.07,0.065,0.045,0.04
##
set cntrparam levels discrete 0.14,0.12,0.09,0.075,0.07,0.065,0.045,0.04

set table "P_1_contours.txt"
splot "../PhiPsi_Bins/P_CONT_1" using 1:2:4 with lines
unset table

set xra [-180:180]
set yra [-180:180]
set xla "Phi"
set yla "Psi"
set title "THR 1 Backbone, GalNAc"
set term post enh color solid 16

set output "P_1.ps"
plot \
     "P_1_contours.txt" i 7 w l lw 2 ti "0.140",\
     "P_1_contours.txt" i 6 w l lw 2 ti "0.120",\
     "P_1_contours.txt" i 5 w l lw 2 ti "0.090",\
     "P_1_contours.txt" i 4 w l lw 2 ti "0.075",\
     "P_1_contours.txt" i 3 w l lw 2 ti "0.070",\
     "P_1_contours.txt" i 2 w l lw 2 ti "0.065",\
     "P_1_contours.txt" i 1 w l lw 2 ti "0.045",\
     "P_1_contours.txt" i 0 w l lw 2 ti "0.040",\
     "../2D_J-Coupling/sorted_2d_1_obs.txt" using 1:2 w points pt 5 lt 10 ps 0.75 ti "2D-J Values", \
     "../PDB/PDB_PhiPsi_all.dat" using 2:3 w points pt 9 lt -1 lw 1 ps 1.25 ti "NMR Struct"

