reset
set size 1,0.25
set origin 0,0.26
unset key
unset title
unset xtics
set ytics (6,7)
set la 1 "Karplus" at 7.9,7.2 right
se xra [3.75:8]
se yra [5:8]
plot "Results_20121227_HNHA_Karplus.dat" using 1:2:3 with yerrorbars,"Results_20121227_HNHA_Karplus.dat" using ($1+0.25):5:6 with yerrorbars,"Results_20121227_HNHA_Karplus.dat" using ($1+0.5):8:9 with yerrorbars

