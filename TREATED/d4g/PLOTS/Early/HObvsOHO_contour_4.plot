set parametric
set contour base
set view 0,0,1
unset surface
set cntrparam levels discrete 1e-6,5e-6,1e-5,5e-5,1e-4,2e-4,4e-4,6e-4
set table "GNC_2D_HObvsOHO_1-2-6_cntr.txt"
set xra [1:9]
set yra [0:180]
splot "../GalNAc/GNC_2D_HObak-OHO.txt" using 1:2:6 with lines
unset table
