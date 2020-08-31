#!/bin/bash

#set xla "O-O distance"
#set yla "H-H distance"

YOffsets=(0.70 0.48 0.26 0.04)
XOffsets=(0.016 0.42 0.56 0.70 0.84)
SetRunLabelPos="at graph 0.1,0.4"
NumberSize="Helv,10"

HHOOTop="reset
unset colorbox
unset key
set xrange [2.0:5.0]
set xtics 1 format \"\"
set yrange [1.0:9.0]
set ytics format \"\"
set grid x
set grid y
unset xla
unset yla
set grid front
set size 0.19,0.26
gamma = 3.2
color(gray) = 1-gray**(1./gamma)
set palette model RGB functions color(gray), color(gray), color(gray)
unset title
"

#set xla "O-O distance"
#set yla "H-H distance"
NNTop="reset
unset key
set xrange [6.0:15.0]
set xtics 1 format \"\"
set ytics format \"\" scale 0  nomirror
set grid x
set grid y
unset xla
unset yla
set grid front
set size 0.40,0.26
unset title
"

# Start main multi-plotting script
echo "reset
set term post enh solid \"Helvetica\" 12
set output \"BigGrid_Multi.ps\"

set multiplot" > BigGrid_Multi.plot

# Explicit
echo "load \"BigGrid_Exp_N.plot\"" >> BigGrid_Multi.plot
echo "${NNTop} 
set origin ${XOffsets[0]},${YOffsets[0]}
set label \"N(THR3) to N(LYS7)\" at graph 0.5,1.1 center
set label \"Hg-Hb (y) vs Ob-Og (x)\" at graph 2,1.1 center
set label \"Explicit\" ${SetRunLabelPos}
plot \"Explicit_NN_bins_bins.txt\" with impulses lt -1
" > BigGrid_Exp_N.plot
for i in 1 2 3 4 ; do 
	echo "load \"BigGrid_Exp_HH-OO_${i}.plot\"" >> BigGrid_Multi.plot
	echo "${HHOOTop}
set label \"Site ${i}\" at graph 0.5,0.8 center front" > BigGrid_Exp_HH-OO_${i}.plot
	if [ "${i}" -eq "1" ] ; then
		echo "
set label \"1\" at graph -0.11,0.03 font \"Helv,10\"
set label \"9\" at graph -0.11,0.97 font \"Helv,10\"
" >> BigGrid_Exp_HH-OO_${i}.plot
	fi
echo "
set origin ${XOffsets[i]},${YOffsets[0]}
plot \"HH-OO_${i}_Expl_XYZ_bins.txt\" using 2:1:6 with image
" >> BigGrid_Exp_HH-OO_${i}.plot
done

# ALPB 7
echo "load \"BigGrid_alpb7_N.plot\"" >> BigGrid_Multi.plot
echo "${NNTop}
set origin ${XOffsets[0]},${YOffsets[1]}
set label \"ALPB 7\" ${SetRunLabelPos}
plot \"alpb7_NN_bins_bins.txt\" with impulses lt -1
" > BigGrid_alpb7_N.plot
for i in 1 2 3 4 ; do 
	echo "load \"BigGrid_alpb7_HH-OO_${i}.plot\"" >> BigGrid_Multi.plot
	echo "${HHOOTop}" > BigGrid_alpb7_HH-OO_${i}.plot
	if [ "${i}" -eq "1" ] ; then
		echo "
set label \"1\" at graph -0.11,0.03 font \"Helv,10\"
set label \"9\" at graph -0.11,0.97 font \"Helv,10\"
" >> BigGrid_alpb7_HH-OO_${i}.plot
	fi
	echo "
set origin ${XOffsets[i]},${YOffsets[1]}
plot \"HH-OO_${i}_alpb7_XYZ_bins.txt\" using 2:1:6 with image
" >> BigGrid_alpb7_HH-OO_${i}.plot
done

# ALPB 2
echo "load \"BigGrid_alpb2_N.plot\"" >> BigGrid_Multi.plot
echo "${NNTop}
set origin ${XOffsets[0]},${YOffsets[2]}
set label \"Relative population\" at graph -0.05,1.01 center rotate
set label \"Distance, Angstroms\" at graph 1.09,1.01 center rotate
set label \"ALPB 2\" ${SetRunLabelPos}
plot \"alpb2_NN_bins_bins.txt\" with impulses lt -1
" > BigGrid_alpb2_N.plot
for i in 1 2 3 4 ; do 
	echo "load \"BigGrid_alpb2_HH-OO_${i}.plot\"" >> BigGrid_Multi.plot
	echo "${HHOOTop}" > BigGrid_alpb2_HH-OO_${i}.plot
	if [ "${i}" -eq "1" ] ; then
		echo "
set label \"1\" at graph -0.11,0.03 font \"Helv,10\"
set label \"9\" at graph -0.11,0.97 font \"Helv,10\"
" >> BigGrid_alpb2_HH-OO_${i}.plot
	fi
	echo "
set origin ${XOffsets[i]},${YOffsets[2]}
plot \"HH-OO_${i}_alpb2_XYZ_bins.txt\" using 2:1:6 with image
" >> BigGrid_alpb2_HH-OO_${i}.plot
done

# Dielectric Only
echo "load \"BigGrid_Diel_N.plot\"" >> BigGrid_Multi.plot
echo "${NNTop}
set origin ${XOffsets[0]},${YOffsets[3]}
set label \"Distance, Angstroms\" at graph 0.5,-0.2 center
set label \"Distance, Angstroms\" at graph 2,-0.2 center
set label \"6\" at graph 0.008,-0.08 font \"Helv,10\"
set label \"15\" at graph 0.95,-0.08 font \"Helv,10\"
set label \"Dielectric\" ${SetRunLabelPos}
plot \"Diel_NN_bins_bins.txt\" with impulses lt -1 lw 0.5
" > BigGrid_Diel_N.plot
for i in 1 2 3 4 ; do 
	echo "load \"BigGrid_Diel_HH-OO_${i}.plot\"" >> BigGrid_Multi.plot
	echo "${HHOOTop}" > BigGrid_Diel_HH-OO_${i}.plot
	if [ "${i}" -eq "1" ] ; then
		echo "
set label \"1\" at graph -0.11,0.03 font \"Helv,10\"
set label \"9\" at graph -0.11,0.97 font \"Helv,10\"
" >> BigGrid_Diel_HH-OO_${i}.plot
	fi
	echo "
set label \"2\" at graph 0.03,-0.08 font \"Helv,10\"
set label \"5\" at graph 0.92,-0.08 font \"Helv,10\"
set origin ${XOffsets[i]},${YOffsets[3]}
plot \"HH-OO_${i}_Diel_XYZ_bins.txt\" using 2:1:6 with image
" >> BigGrid_Diel_HH-OO_${i}.plot
done


echo "unset multiplot" >> BigGrid_Multi.plot
