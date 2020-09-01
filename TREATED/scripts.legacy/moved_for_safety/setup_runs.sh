#!/bin/bash


SETUP="./setup.sh"
if [ $1 ] ; then
	SETUP=$1
fi
. $SETUP
EndBefore=$((NumberOfRuns+StartNumber))

echo "#!/bin/bash

# Building run files for $NumberOfRuns Runs
" > $ControlFileName

## Make the subdirectories
kr=$RunsStartNumber
ki=$InputStartNumber
while [ $ki -le $NumberOfRuns ] ; do
	if [ -d $kr ] ; then
		rm -rf $kr
	fi
	mkdir $kr
	# Make the input files
	File=${kr}/${InputFileName} 
	echo "#!/bin/bash

# Submit a serial pmemd job

export AMBERHOME=${AmberHome}
export PATH=${Path}
export LD_LIBRARY_PATH=${LdLibPath}

" > ${File}

	j=0
	while [ $j -lt $NumberOfRunSteps ] ; do 
		if [ $j -eq 0 ] ; then
			InputCoord=../${MoleculeInputFilePath}/${ki}${InpcrdSuffix}
		fi
		RestartFile="${StepAbbreviations[j]}".rst7
		if [ $j -gt 0 ] ; then
			echo "
if grep -q \"$wallclock\" ${StepAbbreviations[$((j-1))]}.o  ; then" >> ${File}
		fi
		echo "#
# ${StepNames[j]}
#
${Executable} \\
 -p ../${MoleculeInputFilePath}/${ki}${PrmtopSuffix} \\
 -c ${InputCoord} \\
 -i ../${RunInputFilePath}/${InputFiles[j]} \\
 -o ${StepAbbreviations[j]}.o \\
 -r ${RestartFile} \\
 -x ${StepAbbreviations[j]}.nc \\
 -inf ${StepAbbreviations[j]}.info \\
 -l ${StepAbbreviations[j]}.log 
#
" >> ${File}
		if [ $j -gt 0 ] ; then
			echo "
fi "  >> ${File}
		fi
		InputCoord=${RestartFile}
		j=$((j+1))
	done

	echo "cd $kr && nohup bash ${InputFileName} & " >> ${ControlFileName} 
	kr=$((kr+1))
	ki=$((ki+1))
done


