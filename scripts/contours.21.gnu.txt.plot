# set terminal pngcairo  transparent enhanced font "arial,10" fontscale 1.0 size 500, 350 
# set output 'contours.21.png'
set view map
set samples 25, 25
set isosamples 26, 26
unset surface
set contour base
set cntrparam bspline
set cntrparam levels auto 10
set style data lines
set title "3D gnuplot demo - 2D contour projection of last plot" 
set xlabel "X axis" 
set xrange [ 0.00000 : 15.0000 ] noreverse nowriteback
set ylabel "Y axis" 
set yrange [ 0.00000 : 15.0000 ] noreverse nowriteback
set zlabel "Z axis" 
set zlabel  offset character 1, 0, 0 font "" textcolor lt -1 norotate
set zrange [ -1.20000 : 1.20000 ] noreverse nowriteback
splot "glass.dat" using 1
