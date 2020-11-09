set boxwidth 0.9 absolute
set style fill   solid 1.00 border lt -1
#set key fixed right top vertical Right noreverse noenhanced autotitle nobox
set key top left horizontal nobox
set style histogram clustered gap 1 title textcolor lt -1
set datafile missing '-'
set style data histograms
set xtics border in scale 0,0 nomirror 
set xtics  norangelimit 
set xtics   ()
set ytics 0,0.2,1.0
set yrange [ 0.00000 : 1.3 ] noreverse writeback
set grid y

set title "H...O...H Fractions by Test Type and Site" 
set xlabel "Test type"
set ylabel "Fraction"

set arrow 1 from 0,1.05 to 2,1.05 nohead lw 2 
set label 1 "THR 3" at 1,1.1 center

set arrow 2 from 3,1.05 to 5,1.05 nohead lw 2 
set label 2 "THR 4" at 4,1.1 center

set arrow 3 from 6,1.05 to 8,1.05 nohead lw 2 
set label 3 "THR 5" at 7,1.1 center

set arrow 4 from 9,1.05 to 11,1.05 nohead lw 2 
set label 4 "THR 6" at 10,1.1 center

set term post enh color 16
set output "Compare_H-O-H_fractions.ps"
plot 'All_4Way-HOH_t00_site_SUMMARY.dat' using 4:xtic(3) ti col, '' u 5 ti col, '' u 6 ti col

set term png crop
set output "Compare_H-O-H_fractions.png"
plot 'All_4Way-HOH_t00_site_SUMMARY.dat' using 4:xtic(3) ti col, '' u 5 ti col, '' u 6 ti col


