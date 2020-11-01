set parametric
set contour base
set view 0,0,1
unset surface
set cntrparam levels discrete 1e-5,5e-5,1e-4,5e-4,1e-3,2e-3,4e-3
set table "GNC_2D_SUMvsONO_1-2-7_cntr.txt"
set xra [3:12]
set yra [0:180]
splot "../GalNAc/GNC_2D_NOSum-ONO.txt" using 1:2:7 with lines
unset table
set key top right
set title "Normalized fraction over all simulations"
set xla "Distance: N -- O-bak + N -- O-gly"
set yla "O-gly -- N -- O-bak angle"
set term post enh solid color 14
set output "SUMvsONO_contour.eps"
plot \
     "GNC_2D_SUMvsONO_1-2-7_cntr.txt" i 0 w l ti "4e-3",\
     "GNC_2D_SUMvsONO_1-2-7_cntr.txt" i 1 w l ti "2e-3",\
     "GNC_2D_SUMvsONO_1-2-7_cntr.txt" i 2 w l ti "1e-3",\
     "GNC_2D_SUMvsONO_1-2-7_cntr.txt" i 3 w l ti "5e-4",\
     "GNC_2D_SUMvsONO_1-2-7_cntr.txt" i 4 w l ti "1e-4",\
     "GNC_2D_SUMvsONO_1-2-7_cntr.txt" i 5 w l ti "5e-5",\
     "GNC_2D_SUMvsONO_1-2-7_cntr.txt" i 6 w l ti "1e-5"

