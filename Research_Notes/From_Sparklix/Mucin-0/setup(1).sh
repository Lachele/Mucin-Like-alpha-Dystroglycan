#!/bin/bash

## Include this as a file with scripts/set_up_runs.sh

# the number of runs to set up
NumberOfRuns=48
# the number of duplicate runs to set up; this is also the length of RanNums array
RunsStartNumber=1
InputStartNumber=1 
InputFileName=RUN.sh
ControlFileName=RunAll.sh

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
InputFiles=(min.in heat1.in equil1.in prod_protein.in)
AmberHome="/programs/gpu/amber12"
Executable="/programs/gpu/amber12/bin/pmemd"
Path=$PATH:/opt/torque/bin:/programs/gpu/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin
LdLibPath=$LD_LIBRARY_PATH:/programs/lib:/usr/local/lib
LdLibPath=$LD_LIBRARY_PATH:/programs/gpu/lib:/usr/local/lib64:/usr/local/lib:/lib64:/lib:/usr/lib64:/usr/lib
wallclock="Total wall time"



