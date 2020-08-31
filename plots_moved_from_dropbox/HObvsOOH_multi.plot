set term post enh solid color 10
set output "HObvOOH_contour_multi.eps"
set multiplot
reset
set size 0.5,0.5
set origin 0,0.5
set title "GalNAc 1 Normalized fraction over all simulations"
set key bottom left
se xra [1:9]
set xla "H -- O-back distance"
set yla "H -- O-glyc -- O-back angle"
plot \
     "GNC_2D_HObvsOOH_1-2-3_cntr.txt" i 0 w l ti "6e-4",\
     "GNC_2D_HObvsOOH_1-2-3_cntr.txt" i 1 w l ti "4e-4",\
     "GNC_2D_HObvsOOH_1-2-3_cntr.txt" i 2 w l ti "2e-4",\
     "GNC_2D_HObvsOOH_1-2-3_cntr.txt" i 3 w l ti "1e-4",\
     "GNC_2D_HObvsOOH_1-2-3_cntr.txt" i 4 w l ti "5e-5",\
     "GNC_2D_HObvsOOH_1-2-3_cntr.txt" i 5 w l ti "1e-5",\
     "GNC_2D_HObvsOOH_1-2-3_cntr.txt" i 6 w l ti "5e-6",\
     "GNC_2D_HObvsOOH_1-2-3_cntr.txt" i 7 w l ti "1e-6"

reset
set size 0.5,0.5
set origin 0.5,0.5
set title "GalNAc 2 Normalized fraction over all simulations"
set key bottom left
se xra [1:9]
set xla "H -- O-back distance"
set yla "H -- O-glyc -- O-back angle"
plot \
     "GNC_2D_HObvsOOH_1-2-4_cntr.txt" i 0 w l ti "6e-4",\
     "GNC_2D_HObvsOOH_1-2-4_cntr.txt" i 1 w l ti "4e-4",\
     "GNC_2D_HObvsOOH_1-2-4_cntr.txt" i 2 w l ti "2e-4",\
     "GNC_2D_HObvsOOH_1-2-4_cntr.txt" i 3 w l ti "1e-4",\
     "GNC_2D_HObvsOOH_1-2-4_cntr.txt" i 4 w l ti "5e-5",\
     "GNC_2D_HObvsOOH_1-2-4_cntr.txt" i 5 w l ti "1e-5",\
     "GNC_2D_HObvsOOH_1-2-4_cntr.txt" i 6 w l ti "5e-6",\
     "GNC_2D_HObvsOOH_1-2-4_cntr.txt" i 7 w l ti "1e-6"

reset
set size 0.5,0.5
set origin 0,0
set title "GalNAc 3 Normalized fraction over all simulations"
set key bottom left
se xra [1:9]
set xla "H -- O-back distance"
set yla "H -- O-glyc -- O-back angle"
plot \
     "GNC_2D_HObvsOOH_1-2-5_cntr.txt" i 0 w l ti "6e-4",\
     "GNC_2D_HObvsOOH_1-2-5_cntr.txt" i 1 w l ti "4e-4",\
     "GNC_2D_HObvsOOH_1-2-5_cntr.txt" i 2 w l ti "2e-4",\
     "GNC_2D_HObvsOOH_1-2-5_cntr.txt" i 3 w l ti "1e-4",\
     "GNC_2D_HObvsOOH_1-2-5_cntr.txt" i 4 w l ti "5e-5",\
     "GNC_2D_HObvsOOH_1-2-5_cntr.txt" i 5 w l ti "1e-5",\
     "GNC_2D_HObvsOOH_1-2-5_cntr.txt" i 6 w l ti "5e-6",\
     "GNC_2D_HObvsOOH_1-2-5_cntr.txt" i 7 w l ti "1e-6"

reset
set size 0.5,0.5
set origin 0.5,0
set title "GalNAc 4 Normalized fraction over all simulations"
set key bottom left
se xra [1:9]
set xla "H -- O-back distance"
set yla "H -- O-glyc -- O-back angle"
plot \
     "GNC_2D_HObvsOOH_1-2-6_cntr.txt" i 0 w l ti "6e-4",\
     "GNC_2D_HObvsOOH_1-2-6_cntr.txt" i 1 w l ti "4e-4",\
     "GNC_2D_HObvsOOH_1-2-6_cntr.txt" i 2 w l ti "2e-4",\
     "GNC_2D_HObvsOOH_1-2-6_cntr.txt" i 3 w l ti "1e-4",\
     "GNC_2D_HObvsOOH_1-2-6_cntr.txt" i 4 w l ti "5e-5",\
     "GNC_2D_HObvsOOH_1-2-6_cntr.txt" i 5 w l ti "1e-5",\
     "GNC_2D_HObvsOOH_1-2-6_cntr.txt" i 6 w l ti "5e-6",\
     "GNC_2D_HObvsOOH_1-2-6_cntr.txt" i 7 w l ti "1e-6"

unset multiplot
