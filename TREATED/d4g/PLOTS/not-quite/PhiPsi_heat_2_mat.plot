set title "Heat Map generated from a file containing Z values only"
unset key
set tic scale 0

# Color runs from white to green
set palette rgbformula 33,13,10
#set cbrange [0:10000]
set cblabel "Score"
unset cbtics

#set xrange [-180.0:180.0]
#set yrange [-180.0:180.0]

set view map
splot "../PhiPsi_Bins/P_INT_2" matrix with image
