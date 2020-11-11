set boxwidth 0.9 absolute
set style fill   solid 1.00 border lt -1
#set key fixed right top vertical Right noreverse noenhanced autotitle nobox
set key top center horizontal nobox 
set style histogram clustered gap 1 title textcolor lt -1
set datafile missing '-'
set style data histograms
set xtics border in scale 0,0 nomirror 
set xtics  norangelimit 
set xtics   ()
set ytics 0,0.2,1.0
set yrange [ 0.00000 : 1.3 ] noreverse writeback
set grid y

set title "H...O...H Fraction Details for Backbone Oxygen" 
set xlabel "Test type"
set ylabel "Fraction"

set arrow 1 from 0.5,1.05 to 3,1.05 nohead lw 2 
set label 1 "THR 3" at 1.75,1.1 center

set arrow 2 from 3.5,1.05 to 6,1.05 nohead lw 2 
set label 2 "THR 4" at 4.75,1.1 center

set arrow 3 from 6.5,1.05 to 9,1.05 nohead lw 2 
set label 3 "THR 5" at 7.75,1.1 center

set arrow 4 from 9.5,1.05 to 12,1.05 nohead lw 2 
set label 4 "THR 6" at 10.75,1.1 center

set term post enh color 16
set output "H-O-H_fractions_backbone_detail.ps"
plot '../../SPREADSHEETS/backbone_O_details.dat' using 3:xtic(2) ti 'Hb and Hg', '' u 4 ti 'Hb Only', '' u 5 ti 'Hg Only', '' u 6 ti 'Neither'

set term png crop fontscale 0.9
set output "H-O-H_fractions_backbone_detail.png"
plot '../../SPREADSHEETS/backbone_O_details.dat' using 3:xtic(2) ti 'Hb and Hg','' u 4 ti  'Hb Only',  '' u 5 ti 'Hg Only', '' u 6 ti 'Neither'


