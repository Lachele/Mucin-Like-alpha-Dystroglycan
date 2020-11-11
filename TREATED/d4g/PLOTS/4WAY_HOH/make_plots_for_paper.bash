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
set xla \"H - ${oxygenLabel[${3}]} Distance\"
set yla \"H2N - ${oxygenLabel[${3}]} Distance\"
set grid front
set size ratio 2
set object 2 rect from 1,1 to 3.9,3.9 front fs empty border rgb \"#ff000000\" lw 2
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
set title \"THR ${thrNumber}, ${oxygenTitle[${3}]}\"
set term post enh color 16
set output \"${5}.ps\"
plot \"${4}\" using 1:2:5 with image
set term png crop
set output \"${5}.png\"
plot \"${4}\" using 1:2:5 with image
" > ${5}.plot
}

for site in 4 5 6 7 ; do 
	for phase in All All_EQ ; do 
		for oxygen in O OG1 ; do
			Binned_Data_File=${phase}_site-${site}_${oxygen}_binned.dat
			Gnuplot_File_Prefix=PAPER_SINGLE_${phase}_site-${site}_${oxygen}
			echo "The binned data file name is ${Binned_Data_File}"
			write_gnuplot_file ${phase} ${site} ${oxygen} ${Binned_Data_File} ${Gnuplot_File_Prefix}
			gnuplot ${Gnuplot_File_Prefix}.plot
		done
	done
done

