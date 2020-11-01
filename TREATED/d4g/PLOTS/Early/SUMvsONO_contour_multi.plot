set term post enh solid color 10
set output "SUMvsONO_contour_multi.eps"
set multiplot
reset

set size 0.5,0.5
set origin 0,0.5
set key top right
set title "Normalized fraction for GNC 1 over all simulations"
set xla "Distance: N -- O-bak + N -- O-gly"
set yla "O-gly -- N -- O-bak angle"
plot \
     "GNC_2D_SUMvsONO_1-2-3_cntr.txt" i 0 w l ti "4e-3",\
     "GNC_2D_SUMvsONO_1-2-3_cntr.txt" i 1 w l ti "2e-3",\
     "GNC_2D_SUMvsONO_1-2-3_cntr.txt" i 2 w l ti "1e-3",\
     "GNC_2D_SUMvsONO_1-2-3_cntr.txt" i 3 w l ti "5e-4",\
     "GNC_2D_SUMvsONO_1-2-3_cntr.txt" i 4 w l ti "1e-4",\
     "GNC_2D_SUMvsONO_1-2-3_cntr.txt" i 5 w l ti "5e-5",\
     "GNC_2D_SUMvsONO_1-2-3_cntr.txt" i 6 w l ti "1e-5"
reset

set size 0.5,0.5
set origin 0.5,0.5
set key top right
set title "Normalized fraction for GNC 2 over all simulations"
set xla "Distance: N -- O-bak + N -- O-gly"
set yla "O-gly -- N -- O-bak angle"
plot \
     "GNC_2D_SUMvsONO_1-2-4_cntr.txt" i 0 w l ti "4e-3",\
     "GNC_2D_SUMvsONO_1-2-4_cntr.txt" i 1 w l ti "2e-3",\
     "GNC_2D_SUMvsONO_1-2-4_cntr.txt" i 2 w l ti "1e-3",\
     "GNC_2D_SUMvsONO_1-2-4_cntr.txt" i 3 w l ti "5e-4",\
     "GNC_2D_SUMvsONO_1-2-4_cntr.txt" i 4 w l ti "1e-4",\
     "GNC_2D_SUMvsONO_1-2-4_cntr.txt" i 5 w l ti "5e-5",\
     "GNC_2D_SUMvsONO_1-2-4_cntr.txt" i 6 w l ti "1e-5"
reset

set size 0.5,0.5
set origin 0,0
set key top right
set title "Normalized fraction for GNC 3 over all simulations"
set xla "Distance: N -- O-bak + N -- O-gly"
set yla "O-gly -- N -- O-bak angle"
plot \
     "GNC_2D_SUMvsONO_1-2-5_cntr.txt" i 0 w l ti "4e-3",\
     "GNC_2D_SUMvsONO_1-2-5_cntr.txt" i 1 w l ti "2e-3",\
     "GNC_2D_SUMvsONO_1-2-5_cntr.txt" i 2 w l ti "1e-3",\
     "GNC_2D_SUMvsONO_1-2-5_cntr.txt" i 3 w l ti "5e-4",\
     "GNC_2D_SUMvsONO_1-2-5_cntr.txt" i 4 w l ti "1e-4",\
     "GNC_2D_SUMvsONO_1-2-5_cntr.txt" i 5 w l ti "5e-5",\
     "GNC_2D_SUMvsONO_1-2-5_cntr.txt" i 6 w l ti "1e-5"
reset

set size 0.5,0.5
set origin 0.5,0
set key top right
set title "Normalized fraction for GNC 4 over all simulations"
set xla "Distance: N -- O-bak + N -- O-gly"
set yla "O-gly -- N -- O-bak angle"
plot \
     "GNC_2D_SUMvsONO_1-2-6_cntr.txt" i 0 w l ti "4e-3",\
     "GNC_2D_SUMvsONO_1-2-6_cntr.txt" i 1 w l ti "2e-3",\
     "GNC_2D_SUMvsONO_1-2-6_cntr.txt" i 2 w l ti "1e-3",\
     "GNC_2D_SUMvsONO_1-2-6_cntr.txt" i 3 w l ti "5e-4",\
     "GNC_2D_SUMvsONO_1-2-6_cntr.txt" i 4 w l ti "1e-4",\
     "GNC_2D_SUMvsONO_1-2-6_cntr.txt" i 5 w l ti "5e-5",\
     "GNC_2D_SUMvsONO_1-2-6_cntr.txt" i 6 w l ti "1e-5"
reset


unset multiplot
