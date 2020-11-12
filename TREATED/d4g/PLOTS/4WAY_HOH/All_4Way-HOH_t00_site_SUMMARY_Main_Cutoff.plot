reset
set boxwidth 0.7 absolute
set style fill solid 1.00 border lt -1
#set key fixed right top vertical Right noreverse noenhanced autotitle nobox
set key top center horizontal nobox
set style histogram clustered gap 2 title textcolor lt -1
set datafile missing '-'
set style data histograms
set xrange [-0.5:3.5]
set xtics border in scale 0,0 nomirror 
set xtics  norangelimit 
set xtics   ()
set ytics 0,0.2,1.0
set yrange [ 0.00000 : 1.15 ] noreverse writeback
set grid y

set title "Population fractions with a bifurcated H-bond" 
set xlabel "Threonine Residue Number"
set ylabel "Fraction"

set term post enh color 24
set output "Compare_H-O-H_fractions_main_cutoff.ps"
plot '../../SPREADSHEETS/All_4Way-HOH_t00_site_SUMMARY_main_cutoff.dat' using 4:xtic(2) ti col, '' u 5 ti col
#plot '../../SPREADSHEETS/All_4Way-HOH_t00_site_SUMMARY_main_cutoff.dat' using 4:xtic(2) ti col, '' u 5 ti col, '' u 6 ti col

