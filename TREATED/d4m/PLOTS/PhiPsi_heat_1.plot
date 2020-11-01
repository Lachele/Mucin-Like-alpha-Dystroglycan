set xtics border in scale 0,0 mirror norotate  autojustify
set ytics border in scale 0,0 mirror norotate  autojustify
unset colorbox
set xrange [-180.0:180.0]
set yrange [-180.0:180.0]
set grid x
set grid y
set xla "Phi"
set yla "Psi"
set grid front 
set size square
#set cbrange [ 0.00000 : 1000.00000 ] noreverse nowriteback
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)

set title "THR 1 Backbone, Mannose" 

set term post enh color 16
set output "2D_Heat_1.ps"
plot \
   "../PhiPsi_Bins/P_CONT_1" using 1:2:5 with image, \
   "../2D_J-Coupling/Points_in_range_1.txt" using 1:2 w points pt 5 lt 10 ps 0.75 ti "8.33 - 8.35 (8.34) 2D-J", \
   "../PDB/PDB_PhiPsi_all.dat" using 2:3 w points pt 9 lt 7 lw 1 ps 1.5 ti "NMR Struct"
