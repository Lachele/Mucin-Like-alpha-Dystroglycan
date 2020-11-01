reset
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
set key left 
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)

set title "THR 2 Glycosidic Linkage, GalNAc" 

set term post enh color 16
set output "2D_Heat_2-S.ps"
plot \
   "../PhiPsi_Bins/S_CONT_2" using 1:2:5 with image noti, \
   "../PDB/PDB_PhiPsi_all.dat" using 12:13 w points pt 9 lt 7 lw 1 ps 1.5 ti "NMR Struct"

