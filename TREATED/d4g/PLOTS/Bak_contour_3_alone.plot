reset
set term post enh solid color 12
set output "Bak_contour_3_alone.eps"
set xtics border in mirror norotate  autojustify
set ytics border in mirror norotate  autojustify
unset colorbox
unset key
set xrange [2.0:8.0]
set yrange [0:180.0]
set grid x
set grid y
set xla "Ng-Ob Distance, Angstroms"
set yla "Ng-Hg-Ob Angle, Degrees"
set grid front
#set size square
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
set object 1 rectangle from 2,100 to 3,180 fs empty border lt -1 lw 3 front
set object 2 rectangle from 2,40 to 4.5,180 fs empty border lt -1 lw 3 front
se label 1 "1" at 2.25,107 front
se label 2 "2" at 2.25,47 front
se size 0.5,0.5

set title "THR 3"
se origin 0.0,0.0
plot "../GalNAc/GNC_2D_bak.txt" using 1:2:5 with image

