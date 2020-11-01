
set parametric
set contour base
set view 0,0,1
unset surface
set cntrparam levels discrete 1e-5,5e-5,1e-4,5e-4,1e-3,2e-3,4e-3
set table "GNC_2D_SUMvsONO_1-2-3_cntr.txt"
set xra [3:12]
set yra [0:180]
splot "../GalNAc/GNC_2D_NOSum-ONO.txt" using 1:2:3 with lines
unset table

set parametric
set contour base
set view 0,0,1
unset surface
set cntrparam levels discrete 1e-5,5e-5,1e-4,5e-4,1e-3,2e-3,4e-3
set table "GNC_2D_SUMvsONO_1-2-4_cntr.txt"
set xra [3:12]
set yra [0:180]
splot "../GalNAc/GNC_2D_NOSum-ONO.txt" using 1:2:4 with lines
unset table

set parametric
set contour base
set view 0,0,1
unset surface
set cntrparam levels discrete 1e-5,5e-5,1e-4,5e-4,1e-3,2e-3,4e-3
set table "GNC_2D_SUMvsONO_1-2-5_cntr.txt"
set xra [3:12]
set yra [0:180]
splot "../GalNAc/GNC_2D_NOSum-ONO.txt" using 1:2:5 with lines
unset table

set parametric
set contour base
set view 0,0,1
unset surface
set cntrparam levels discrete 1e-5,5e-5,1e-4,5e-4,1e-3,2e-3,4e-3
set table "GNC_2D_SUMvsONO_1-2-6_cntr.txt"
set xra [3:12]
set yra [0:180]
splot "../GalNAc/GNC_2D_NOSum-ONO.txt" using 1:2:6 with lines
unset table

