#!/bin/bash


write_gnuplot_file() {
declare -A simPhase=(
[All]='Production'
[All_EQ]='Initial Equilbrated'
)
declare -A oxygenTitle=(
[O]='Backbone O'
[OG1]='Glycosidic O'
)
declare -A oxygenLabel=(
[O]='Ob'
[OG1]='Og'
)
declare -A originX=(
[4]='0.10'
[5]='0.30'
[6]='0.50'
[7]='0.70'
)
declare -A originY=(
[O]='0.04'
[OG1]='0.5'
)
thisSite="${2}"
thrNumber=$((thisSite-1))
echo "# input file for gnuplot
set xtics border in scale 0,0 mirror norotate autojustify
set ytics border in scale 0,0 mirror norotate autojustify
unset colorbox
unset key
set xrange [1.0:5.0]
set yrange [1.0:9.0]
set xtics 1
set ytics 1
set grid x
set grid y
#set xla \"H - ${oxygenLabel[${3}]} Distance\"
#set yla \"H2N - ${oxygenLabel[${3}]} Distance\"
set grid front
set object 2 rect from 1,1 to 3.9,3.9 front fs empty border rgb \"#ff000000\" lw 2
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
#set title \"THR ${thrNumber}, ${oxygenTitle[${3}]}\"
#set title \"THR ${thrNumber}\"
unset title
set size 0.2,0.46
set origin ${originX[${2}]},${originY[${3}]}
plot \"${4}\" using 1:2:5 with image
" > ${5}.plot
}

for site in 4 5 6 7 ; do 
	for phase in All All_EQ ; do 
		for oxygen in O OG1 ; do
			Binned_Data_File=${phase}_site-${site}_${oxygen}_binned.dat
			Gnuplot_File_Prefix=PAPER_MULTI_${phase}_site-${site}_${oxygen}
			echo "The binned data file name is ${Binned_Data_File}"
			write_gnuplot_file ${phase} ${site} ${oxygen} ${Binned_Data_File} ${Gnuplot_File_Prefix}
			#gnuplot ${Gnuplot_File_Prefix}.plot
		done
	done
done

