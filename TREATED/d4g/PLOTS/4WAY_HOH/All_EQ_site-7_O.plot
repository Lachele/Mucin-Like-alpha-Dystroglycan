# input file for gnuplot
set xtics border in scale 0,0 mirror norotate  autojustify
set ytics border in scale 0,0 mirror norotate  autojustify
unset colorbox
unset key
set xrange [1.0:5.0]
set yrange [1.0:9.0]
set grid x
set grid y
set xla "H - O Distance"
set yla "H2N - O Distance"
set grid front
set size square
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
set title "THR 6, O (Initial Equilbrated)"
set term post enh color 16
set output "All_EQ_site-7_O.ps"
plot "All_EQ_site-7_O_binned.dat" using 1:2:5 with image

