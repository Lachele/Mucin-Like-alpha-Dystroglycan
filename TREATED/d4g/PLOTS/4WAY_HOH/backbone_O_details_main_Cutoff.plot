reset
set boxwidth 0.7 absolute
set style fill solid 1.00 border lt -1
#set key fixed right top vertical Right noreverse noenhanced autotitle nobox
set key top center horizontal nobox 
set style histogram clustered gap 2 title textcolor lt -1
set datafile missing '-'
set style data histograms
set xrange [0.5:4.5]
set xtics border in scale 0,0 nomirror 
set xtics  norangelimit 
set xtics   ()
set ytics 0,0.2,0.8
set yrange [ 0.00000 : 1.0 ] noreverse writeback
set grid y

set title "Bifurcated H-bond population details for backbone oxygen" 
set xlabel "Threonine Residue Number"
set ylabel "Fraction"

set term post enh color 24
set output "H-O-H_fractions_backbone_detail_main_cutoff.ps"
plot '../../SPREADSHEETS/backbone_O_details_main_cutoff.dat' using 4:xtic(2) ti 'Hb and Hg', '' u 5 ti 'Hb Only', '' u 6 ti 'Hg Only', '' u 7 ti 'Neither'

