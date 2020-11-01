#!/bin/bash


gnuplot Bak_contour_1.plot
gnuplot Bak_contour_2.plot
gnuplot Bak_contour_3.plot
gnuplot Bak_contour_4.plot
gnuplot Bak_contour_multi.plot
ps2pdf Bak_contour_multi.eps

gnuplot Bak_contour.plot
ps2pdf Bak_contour.eps

gnuplot Gly_contour.plot
ps2pdf Gly_contour.eps

gnuplot HObvsOHO_contour_1.plot
gnuplot HObvsOHO_contour_2.plot
gnuplot HObvsOHO_contour_3.plot
gnuplot HObvsOHO_contour_4.plot
gnuplot HObvsOHO_contour.plot
ps2pdf HObvsOHO_contour.eps

gnuplot HObvsOHO_multi.plot
ps2pdf HObvOHO_contour_multi.eps

gnuplot HOg_hist_multi.plot
ps2pdf HOg_hist_multi.eps
ps2pdf HOg_hist_all.eps

gnuplot HOgvsOHO_contour.plot
ps2pdf HOgvsOHO_contour.eps

gnuplot LenSum.plot
ps2pdf SumAll.eps

gnuplot N-O-bak.plot
ps2pdf N-O-Bak.eps

gnuplot N-O-gly.plot
ps2pdf N-O-Gly.eps

gnuplot Sum_contour_1.plot
gnuplot Sum_contour_2.plot
gnuplot Sum_contour_3.plot
gnuplot Sum_contour_4.plot
gnuplot Sum_contour_multi.plot
ps2pdf Sum_contour_multi.eps

gnuplot SUMvsOHO_contour.plot
ps2pdf SUMvsOHO_contour.eps

gnuplot SUMvsONO_contour.plot
ps2pdf SUMvsONO_contour.eps
