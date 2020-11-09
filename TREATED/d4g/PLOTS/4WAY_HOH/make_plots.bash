#!/bin/bash


write_gnuplot_file() {
declare -A simPhase=(
[All]='Production'
[All_EQ]='Initial Equilbrated'
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
set xla \"H - ${3} Distance\"
set yla \"H2N - ${3} Distance\"
set grid front
set size ratio 2
set object 1 rect from 1,1 to 3.5,3.5 front fs empty border rgb \"#ffbbbbbb\" lw 4
set object 2 rect from 1,1 to 3.9,3.9 front fs empty border rgb \"#ff888888\" lw 4
set object 3 rect from 1,1 to 3.6,4.5 front fs empty border rgb \"#ff000000\" lw 4
set label 1 \"a\" at 1.2,3.7 front
set label 2 \"b\" at 1.2,4.1 front
set label 3 \"c\" at 1.2,4.7 front
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
set title \"THR ${thrNumber}, ${3} (${simPhase[${1}]})\"
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
			Gnuplot_File_Prefix=${phase}_site-${site}_${oxygen}
			echo "The binned data file name is ${Binned_Data_File}"
			write_gnuplot_file ${phase} ${site} ${oxygen} ${Binned_Data_File} ${Gnuplot_File_Prefix}
			gnuplot ${Gnuplot_File_Prefix}.plot
		done
	done
done

