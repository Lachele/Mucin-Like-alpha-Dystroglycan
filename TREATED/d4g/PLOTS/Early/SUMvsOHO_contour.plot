set parametric
set contour base
set view 0,0,1
unset surface
#set cntrparam levels discrete 5e-6,1e-5,5e-5,1e-4,2e-4,4e-4,6e-4,8e-4
set cntrparam levels discrete 1e-6,5e-6,1e-5,5e-5,1e-4,2e-4,4e-4,6e-4
set table "GNC_2D_SUMvsOHO_1-2-7_cntr.txt"
set xra [3:12]
set yra [0:180]
splot "../GalNAc/GNC_2D_HOSUM-OHO.txt" using 1:2:7 with lines
unset table
set key top right
set title "Normalized fraction over all simulations"
set xla "Distance: H -- O-bak + H -- O-gly"
set yla "O-gly -- H -- O-bak angle"
set term post enh solid color 14
set output "SUMvsOHO_contour.eps"
plot "GNC_2D_SUMvsOHO_1-2-7_cntr.txt" i 0 w l lw 2 ti "6e-4",\
     "GNC_2D_SUMvsOHO_1-2-7_cntr.txt" i 1 w l ti "4e-4",\
     "GNC_2D_SUMvsOHO_1-2-7_cntr.txt" i 2 w l ti "2e-4",\
     "GNC_2D_SUMvsOHO_1-2-7_cntr.txt" i 3 w l ti "1e-4",\
     "GNC_2D_SUMvsOHO_1-2-7_cntr.txt" i 4 w l ti "5e-5",\
     "GNC_2D_SUMvsOHO_1-2-7_cntr.txt" i 5 w l ti "1e-5",\
     "GNC_2D_SUMvsOHO_1-2-7_cntr.txt" i 6 w l ti "5e-6",\
     "GNC_2D_SUMvsOHO_1-2-7_cntr.txt" i 7 w l ti "1e-6"

