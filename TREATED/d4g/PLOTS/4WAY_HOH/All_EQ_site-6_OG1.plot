# input file for gnuplot
set xtics border in scale 0,0 mirror norotate  autojustify
set ytics border in scale 0,0 mirror norotate  autojustify
unset colorbox
unset key
set xrange [1.0:5.0]
set yrange [1.0:9.0]
set grid x
set grid y
set xla "H - OG1 Distance"
set yla "H2N - OG1 Distance"
set grid front
set size square
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
set title "THR 5, OG1 (Initial Equilbrated)"
set term post enh color 16
set output "All_EQ_site-6_OG1.ps"
plot "All_EQ_site-6_OG1_binned.dat" using 1:2:5 with image

