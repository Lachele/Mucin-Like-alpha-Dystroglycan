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
set xla "H - Ob Distance"
set yla "H2N - Ob Distance"
set grid front
set size ratio 2
set object 2 rect from 1,1 to 3.9,3.9 front fs empty border rgb "#ff000000" lw 2
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
set title "THR 5, Backbone O"
set term post enh color 16
set output "PAPER_SINGLE_All_EQ_site-6_O.ps"
plot "All_EQ_site-6_O_binned.dat" using 1:2:5 with image
set term png crop
set output "PAPER_SINGLE_All_EQ_site-6_O.png"
plot "All_EQ_site-6_O_binned.dat" using 1:2:5 with image

