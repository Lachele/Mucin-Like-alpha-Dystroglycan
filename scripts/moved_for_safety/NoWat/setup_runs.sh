#!/bin/bash

###
###  THIS IS ONLY FOR d4g
###
###  CALL ME FROM THE DIRECTORY  d4g/NoWat
###
###
###  NOTE!!!!
###
###	This script is destructive.  It completely removes and re-makes the
###		input directories.  It is meant to be run *once* at the beginning
###		of the setup, before data collection begins
###
###
###
## This script does these things:
##
##	Makes sub-directories for each run
##
##		There are 12 types of run, and 32 starting structures for each
##
##	Make run-control scripts for each run and for each starting structure
##
##		Simulation input files will be the same for each run type
##		These are meant to run on Eliot nodes, so all 32 will run at once
##			Each run-type directory will contain a master run control
##				file that will start all 32 on the node
##
##		The parm file for each set of 32 will be in the top-level directory
##			they will use the previous .rst7 files as initial input
##		Each RUN.sh file will be in each directory because it must
##			it will contain min, heat, equil and prod
##
##

. setup.sh  ## This file needs to be in the directory

## Make parm file directory and parms
if [ ! -e ${ParmDir} ] ; then
	echo "Dont forget to make your Parms!!!!"
fi

## Make IS variant directories and the 32 run sub-directories
rt=0 # run type
radt=0 # radii type
###
###  For each type of run 
###
while [ $rt -lt ${NumTypes} ] ; do
	if [ -d "${RunType[rt]}" ] ; then
		rm -rf "${RunType[rt]}" 
	fi
	mkdir "${RunType[rt]}" 
	## Make the job submission script for torque
	RTFile="${RunType[rt]}/Run_All.bash" 
	echo "#!/bin/bash

# Submit a job to run all 32 of this run type

#PBS -q md 
#PBS -l nodes=1:ppn=32 
#PBS -N All_${RunType[rt]} 
#PBS -j oe 

cd \$PBS_O_WORKDIR

../do_all_32.bash    ### This file needs to be in the upper directory (sym-link or copied)
" > ${RTFile}

	## Make the input files for these runs
	##
	## First, get the igb-specific parts settled
	##
	if [ "${ISClass[rt]}" = "na" ] ; then  ## for just dielectric
	ISParts="dielc = ${isDiel}, cut = ${isCut}, rgbmax = ${isRgbmax},
  igb = ${IGBVal[rt]}, extdiel = ${isExtdiel},
"
	elif [ "${ISClass[rt]}" = "PB" ] ; then ## for Poisson-Boltzmann 
	ISParts="dielc = ${isDiel}, cut = ${isCut}, igb = ${IGBVal[rt]}, inp = 1, 
  radiopt=0, istrng=25, epsout=78.5,
"
	else    ## For igb and alpb type IS
	ISParts="dielc = ${isDiel}, cut = ${isCut}, igb = ${IGBVal[rt]}, 
  rgbmax = ${isRgbmax}, extdiel = ${isExtdiel},
  rbornstat = ${isRbornstat}, saltcon = ${isSaltcon},
"
	fi
	if [ "${ISClass[rt]}" = "alpb" ] ; then   ## add extra stuff if we have alpb
		ISParts="${ISParts}  alpb = 1, arad = ${isArad},
"	
	fi
	
#echo "ISParts is >>${ISParts}<<"

### Minimization input file
	echo "# implicit solvent (or similar) minimization
 &cntrl
  imin = 1, ntpr = 100, ntb = 0, ntp = 0, 
  maxcyc = ${MinSteps}, ncyc = ${MinSteps}, 
  ${ISParts} /
" > "${RunType[rt]}/min.in"
### Heating input file
	echo "# implicit solvent (or similar) heating
 &cntrl
  ntwx = ${Heatwx}, ntpr = 500, 
  ntt = 1, temp0 = 300.0, tempi = 5.0, tautp = 1.0, 
  ntb = 0, ntc = 2, ntf = 2, nstlim = ${HeatSteps}, dt = 0.0020, 
  ntp = 0, ibelly = 0, ntr = 0, 
  imin = 0, irest = 0, ntx = 1, nmropt = 1, 
  nrespa = ${isNrespa}, 
  ${ISParts} /
 &wt
  type = 'TEMP0', istep1 = 1, istep2 = ${HeatSteps}, value1 = 5.0, value2 = 300.0, 
 /
 &wt
  type='END'
 /
END
" > "${RunType[rt]}/heat.in"
### Equilibration input file
	echo "# implicit solvent (or similar) equilibration
 &cntrl
  ntwx = ${Equilwx}, ntpr=5000, ntave = 1000, 
  ntt = 3, temp0 = 300.0, tempi = 300.0, 
  tautp = 1.0, gamma_ln=5.0, ig=3762986,
  ntb = 0, ntc = 2, ntf = 2, 
  nstlim = ${EquilSteps}, dt = 0.0020, 
  ntp = 0, taup = 2.0, comp = 44.6, pres0 = 1.0, 
  imin = 0, irest = 1, ntx = 5,
  nrespa = ${isNrespa}, 
  ${ISParts} /
 &wt
  type='END'
 /
END
" > "${RunType[rt]}/equil.in"
### Production input file
	echo "# implicit solvent (or similar) production
 &cntrl
  ntwx = ${Prodwx}, ntpr = 1000, ntave = 5000,
  ntt = 3, temp0 = 300.0, tempi = 300.0, 
  tautp = 1.0, gamma_ln=5.0, ig=3762986,
  ntb = 0, ntc = 2, ntf = 2, 
  nstlim = ${ProdSteps}, dt = 0.0020, 
  ntp = 0, taup = 2.0, comp = 44.6, pres0 = 1.0, 
  imin = 0, irest = 1, ntx = 5,
  nrespa = ${isNrespa}, 
  ${ISParts} /
 &wt
  type='END'
 /
END
" > "${RunType[rt]}/prod.in"
#


###
###  For each of the 32 runs
###
	rn=${RunsStartNumber} # the actual run number
	while [ $rn -le $NumberOfRuns ] ; do
		# Make the input files
		mkdir "${RunType[rt]}/${rn}"
		File="${RunType[rt]}/${rn}/Run.bash"
		echo "#!/bin/bash

# Run a serial sander job

export AMBERHOME=${AmberHome}
export PATH=${Path}
export LD_LIBRARY_PATH=${LdLibPath}

" > ${File}
thisParmFile="../../${ParmDir}/${RadiiSets[rt]}${ParmSuffix}"
		j=0
		while [ $j -lt $NumberOfRunSteps ] ; do 
			if [ $j -eq 0 ] ; then
				InputCoord=${MoleculeInputFilePath}/${rn}.rst7
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
 -p ${thisParmFile} \\
 -c ${InputCoord} \\
 -i ../${InputFiles[j]} \\
 -o ${StepAbbreviations[j]}.o \\
 -r ${RestartFile} \\
 -x ${StepAbbreviations[j]}.nc \\
 -inf ${StepAbbreviations[j]}.info 
#
" >> ${File}
			if [ $j -gt 0 ] ; then
				echo "
fi "  >> ${File}
			fi
			InputCoord=${RestartFile}
			j=$((j+1))
		done
		rn=$((rn+1))
	done
	rt=$((rt+1))
done

