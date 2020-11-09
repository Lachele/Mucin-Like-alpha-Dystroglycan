# input file for gnuplot
set xtics border in scale 0,0 mirror norotate autojustify
set ytics border in scale 0,0 mirror norotate autojustify
unset colorbox
unset key
set xrange [1.0:5.0]
set yrange [1.0:9.0]
set xtics 1
set ytics 1
set grid x
set grid y
set xla "H - O Distance"
set yla "H2N - O Distance"
set grid front
set size ratio 2
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
set title "THR 4, O (Production)"
set term post enh color 16
set output "All_site-5_O.ps"
plot "All_site-5_O_binned.dat" using 1:2:5 with image
set term png crop
set output "All_site-5_O.png"
plot "All_site-5_O_binned.dat" using 1:2:5 with image

