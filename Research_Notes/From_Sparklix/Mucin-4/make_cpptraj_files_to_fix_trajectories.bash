#!/bin/bash

# This should be run from the DLIVE/${IAM}/FIX directory
. ../cpptraj_setup.bash

#export AMBERHOME=/programs/amber
export AMBERHOME=/programs/amber12
CPPTRAJ="${AMBERHOME}/bin/cpptraj"
FIXCOORDS="../../scripts/src/fix_bad_data/fix_coords"
i=1
j=1
CheckForRestarts="2 3 4"  # uses variable k
PTRAJ_FILE_1="" # the trajin file that:
		#  -- concatenates multiple restarts into one trajectory
		#  -- creates a plain-text crd file that can be used (easily) to
		#     fix the occasional zeros produced during the RAID degradation
PTRAJ_FILE_2="" # the trajin file that:
		#  -- converts the zeros-removed plain-text crd back to a .nc file
LEAVE_CRD_FILES="yes" # Say no if you want to delete the (large) interim crd files

TESTWRITE="no" # yes=only make files; no=do the runs

TOPFILE1="../input/Single.parm7"
TOPFILE2="../input/Single.parm7"
# Set the first topology file to use if 0MA or prot
if [ "${IAM}" = "0MA" ] ; then 
	TOPFILE1="../input/plus8water.parm7"
fi
if [ "${IAM}" = "prot" ] ; then 
	TOPFILE1="../input/plus28water.parm7"
fi

# Let us know things are working
echo "MAXRUNS is ${MAXRUNS}"

# set for testing if need
#MAXRUNS=3

# Check for directories and fix files if they exist

while [ "$i" -le "$MAXRUNS" ] ; do
	echo "checking for ../${i}/"
	if [ ! -d "../${i}/" ] ; then
		i=$((i+1))
		continue
	fi
	echo "Found ../${i}/ and going forward."
	PTRAJ_INPUT_1="0_initial_trajectory_manipulation_cpptraj_${i}.in"
	PTRAJ_INPUT_2="1_transform_fixed_trajectory_cpptraj_${i}.in"

	# Start contents of the initial trajectory manipulation input file
	PTRAJ_FILE_1="trajin ../${i}/prod.nc"
	for k in ${CheckForRestarts}; do
		echo "checking for restarts for $k and run $i"
		if [ -e ../${i}/prod${k}.nc ] ; then
			echo "    found restarts and doing stuff"
			PTRAJ_FILE_1="${PTRAJ_FILE_1}\ntrajin ../${i}/prod${k}.nc" 
		fi

	done 
	# Add command to remove extra waters if 0MA or prot
	if [[  "${IAM}" = "0MA"  ||  "${IAM}" = "prot"  ]] ; then 
		PTRAJ_FILE_1="${PTRAJ_FILE_1}\nstrip :WAT"
	fi
	# Add command to concatenate nc files into one trajectory
	PTRAJ_FILE_1="${PTRAJ_FILE_1}\ntrajout ../${i}/prod_all_raw.nc netcdf"
	# Add command to make a plain-text coordinate file (to remove zeros due to hardware malfunction) 
	PTRAJ_FILE_1="${PTRAJ_FILE_1}\ntrajout ../${i}/prod_all_raw.crd trajectory nobox"
	# Add final "go" command
	PTRAJ_FILE_1="${PTRAJ_FILE_1}\ngo\n"

	# Make the file for transforming the CRD file back to .nc
	PTRAJ_FILE_2="trajin ../${i}/prod_all_fixed.crd\ntrajout ../${i}/prod_all_fixed.nc netcdf\ngo\n"

	echo -e ${PTRAJ_FILE_1} > ${PTRAJ_INPUT_1}
### Uncomment the following and the noted lines below, to change the crd files back to nc
	#echo -e ${PTRAJ_FILE_2} > ${PTRAJ_INPUT_2}

	# Prove that the command line will be sane
	if [ "${TESTWRITE}" = "yes" ] ; then 
		echo "The following commands would have been executed for set ${i} of molecule ${IAM}:"
	#else
		#echo "The following commands will be executed for set ${i} of molecule ${IAM}:" 
	#fi 
	echo "${CPPTRAJ} -i ${PTRAJ_INPUT_1} -p ${TOPFILE1}"
	echo "${FIXCOORDS} ${TOPFILE2} ../${i}/prod_all_raw.crd ../${i}/prod_all_fixed.crd ../${i}/prod_all_deleted.crd ../${i}/fixcoords.log"
	fi

### Uncomment the following and the noted lines above/below, to change the crd files back to nc
	#echo "${CPPTRAJ} -i ${PTRAJ_INPUT_2} -p ${TOPFILE2}"

	# If instructed, then go ahead and execute
	if [ "${TESTWRITE}" = "no" ] ; then 
		${CPPTRAJ} -i ${PTRAJ_INPUT_1} -p ${TOPFILE1}
		${FIXCOORDS} ${TOPFILE2} ../${i}/prod_all_raw.crd ../${i}/prod_all_fixed.crd ../${i}/prod_all_deleted.crd ../${i}/fixcoords.log
### Uncomment the following and the noted lines above, to change the crd files back to nc
		#${CPPTRAJ} -i ${PTRAJ_INPUT_2} -p ${TOPFILE2} 
	fi
	i=$((i+1)) 
done


