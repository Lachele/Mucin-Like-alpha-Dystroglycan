#!/bin/bash

## This is sourced with scripts/set_up_runs.sh
##
## It should be placed in your run directory -- the one that
##	will contain all the numbered subdirectories

# the number of runs to set up
NumberOfRuns=16 
# the number of duplicate runs to set up; this is also the length of RanNums array
RunsStartNumber=17 
InputStartNumber=1 

### information about the runs
# these need to be sequential, that is, each uses restart from the previous
# except, of course, the first
RunInputFilePath=".."
MoleculeInputFilePath="input"
PrmtopSuffix="_SolCl.parm7"
InpcrdSuffix="_SolCl.rst7"
NumberOfRunSteps=4
StepNames=(Minimization Heating Equilibration Production)
StepAbbreviations=(min heat equil prod)
InputFiles=(min.in heat.in equil.in prod.in)
AmberHome="/programs/amber12"
Executable="/programs/amber12/bin/pmemd"
Path=$PATH:/usr/lib64/qt-3.3/bin:/usr/kerberos/bin:/programs/bin:/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:/opt/torque/bin
LdLibPath=$LD_LIBRARY_PATH:/programs/lib:/usr/local/lib
wallclock="Master Total wall time"



