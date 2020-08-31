reset
set size 1,0.25
set origin 0,0.72
unset key
unset title
unset xtics
set ytics (8,9)
set la 1 "Observed" at 7.8,9.2 right
set la 2 "J-Coupling Values for Threonine Residues" at 5.75,10.4 center
se xra [3.75:8]
se yra [7:10]
plot "Results_20121227_HNHA_Obs.dat" using 1:2,"Results_20121227_HNHA_Obs.dat" using ($1+0.25):3,"Results_20121227_HNHA_Obs.dat" using ($1+0.5):4

