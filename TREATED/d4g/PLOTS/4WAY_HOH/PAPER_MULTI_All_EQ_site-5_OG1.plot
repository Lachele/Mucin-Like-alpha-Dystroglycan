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
#set xla "H - Og Distance"
#set yla "H2N - Og Distance"
set grid front
set object 2 rect from 1,1 to 3.9,3.9 front fs empty border rgb "#ff000000" lw 2
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
#set title "THR 4, Glycosidic O"
#set title "THR 4"
unset title
set size 0.2,0.46
set origin 0.30,0.5
plot "All_EQ_site-5_OG1_binned.dat" using 1:2:5 with image

