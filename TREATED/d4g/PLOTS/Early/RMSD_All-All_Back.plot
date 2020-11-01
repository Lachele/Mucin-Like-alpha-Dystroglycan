reset
set size 1,0.5
set style rect fc lt -1 fs solid 0.15 noborder
se obj 1 rect from 0,0 to 9951,4
se obj 3 rect from 19911,0 to 29820,4
se obj 5 rect from 39762,0 to 49029,4
se obj 7 rect from 58937,0 to 68888,4  
se obj 9 rect from 78139,0 to 88075,4
se obj 11 rect from 98021,0 to 107398,4
se obj 13 rect from 117326,0 to 130146,4
se obj 15 rect from 140059,0 to 149988,4 
se obj 17 rect from 159923,0 to 169873,4 
se obj 19 rect from 179813,0 to 189216,4
se obj 21 rect from 199141,0 to 209095,4
se obj 23 rect from 218487,0 to 228420,4
se obj 25 rect from 238370,0 to 248318,4
se obj 27 rect from 258240,0 to 268142,4
se obj 29 rect from 278087,0 to 288001,4
se obj 31 rect from 297909,0 to 307808,4

se label "GalNAc" at 100000,3.75
set xla "Frame Index"
se yla "RMSD"
unset key

se xra [0:317739]
se yra [0:4]

se obj 7 rect from 58937,0 to 68888,4   fc lt -1 fs solid 0.40 noborder 
set term post enh solid 16
set output "GalNAc_RMSD_1-to-All.ps"
plot "Back_rmsd_All2All.dat" using 1:8 with lines lt -1

se obj 7 rect from 58937,0 to 68888,4 
se obj 16 rect from 149988,0 to 159923,4 fc lt -1 fs solid 0.40 noborder 
set term post enh solid 16
set output "GalNAc_RMSD_1-to-All_low.ps"
plot "Back_rmsd_All2All.dat" using 1:19 with lines lt -1
