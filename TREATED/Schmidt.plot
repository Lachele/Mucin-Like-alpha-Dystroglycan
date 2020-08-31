reset
set size 1,0.25
set origin 0,0.03
unset key
unset title
unset xtics
set ytics (6,7)
set la 1 "Schmidt" at 7.9,7.2 right
set la 2 "T3" at 4.25,4.6 center
set la 3 "T4" at 5.25,4.6 center
set la 4 "T5" at 6.25,4.6 center
set la 5 "T6" at 7.25,4.6 center
se xra [3.75:8]
se yra [5:8]
plot "Results_20121227_HNHA_Schmidt.dat" using 1:2:3 with yerrorbars,"Results_20121227_HNHA_Schmidt.dat" using ($1+0.25):5:6 with yerrorbars,"Results_20121227_HNHA_Schmidt.dat" using ($1+0.5):8:9 with yerrorbars

