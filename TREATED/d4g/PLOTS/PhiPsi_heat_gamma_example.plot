set xtics border in scale 0,0 mirror norotate  autojustify
set ytics border in scale 0,0 mirror norotate  autojustify
unset colorbox
unset title 
set xrange [-180.0:180.0]
set yrange [-180.0:180.0]
set grid x
set grid y
set xla "Phi"
set yla "Psi"
set grid front 
set size square
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)

plot "P_CONT_1" using 1:2:5 with image

