#!/bin/bash
DATA_LOCATION='4WAY_HOH'
INPUT_LOCATION='../PLOTS/4WAY_HOH'
EXEFILE='../../scripts/src/bin_PhiPsi/bin_two_columns'

declare -A First_Col=(
    [O]='2'
    [OG1]='3'
)
declare -A Second_Col=(
    [O]='4'
    [OG1]='5'
)

write_input_file() {
echo "Data_File=${DATA_LOCATION}/${1}_4Way-HOH_t00_site_${2}.dat
Output_File=${INPUT_LOCATION}/${1}_site-${2}_${3}_binned.dat
Num_Bins=800
First_Col=${First_Col[${3}]}
First_Min=1.0
First_Max=9.0
Second_Col=${Second_Col[${3}]}
Second_Min=1.0
Second_Max=9.0
" > ${INPUT_LOCATION}/${4}
}

for site in 4 5 6 7 ; do 
	for phase in All All_EQ ; do 
		for oxygen in O OG1 ; do
			INPUT_FILE_NAME=${phase}_site-${site}_${oxygen}_binning_input.txt
			echo "The input file name is ${INPUT_FILE_NAME}"
			write_input_file ${phase} ${site} ${oxygen} ${INPUT_FILE_NAME}
			${EXEFILE} ${INPUT_LOCATION}/${INPUT_FILE_NAME}
		done
	done
done

