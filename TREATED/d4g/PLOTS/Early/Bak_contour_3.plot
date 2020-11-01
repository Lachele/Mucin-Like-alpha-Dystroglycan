set parametric
set contour base
set view 0,0,1
unset surface
#set cntrparam levels discrete 5e-6,1e-5,5e-5,1e-4,2e-4,4e-4,6e-4,8e-4
set cntrparam levels discrete 1e-6,5e-6,1e-5,5e-5,1e-4,2e-4,4e-4,6e-4
set table "GNC_2D_bak_1-2-5_cntr.txt"
splot "../GalNAc/GNC_2D_bak.txt" using 1:2:5 with lines
unset table
#set title "GalNAc 3 Normalized fraction over all simulations"
#set key bottom left
#set xla "N -- O-back distance"
#set yla "N -- H -- O-back angle"
#set term post enh solid color 14
#set output "Bak_contour_3.eps"
#plot \
     #"GNC_2D_bak_1-2-5_cntr.txt" i 0 w l ti "6e-4",\
     #"GNC_2D_bak_1-2-5_cntr.txt" i 1 w l ti "4e-4",\
     #"GNC_2D_bak_1-2-5_cntr.txt" i 2 w l ti "2e-4",\
     #"GNC_2D_bak_1-2-5_cntr.txt" i 3 w l ti "1e-4",\
     #"GNC_2D_bak_1-2-5_cntr.txt" i 4 w l ti "5e-5",\
     #"GNC_2D_bak_1-2-5_cntr.txt" i 5 w l ti "1e-5",\
     #"GNC_2D_bak_1-2-5_cntr.txt" i 6 w l ti "5e-6",\
     #"GNC_2D_bak_1-2-5_cntr.txt" i 7 w l ti "1e-6"

