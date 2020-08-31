#!/bin/bash

## Include this as a file with scripts/moved_for_safety/NoWat/set_up_runs.sh
## Copy it to, or link it within the d4g/NoWat directory

# the run types to set up
ISClasses=(na PB igb alpb)
NumTypes=11
ISClass=(na    PB igb  igb  igb  igb  igb  alpb  alpb  alpb  alpb)
RunType=(Diel pb igb1 igb2 igb5 igb7 igb8 alpb1 alpb2 alpb5 alpb7)
IGBVal=(6     10  1    2    5    7    8    1     2     5     7)
# the corresponding intrinsic radii sets 
#   values for HiDiel and pb are irrelevant;
#   they are given values that will have no effect
RadiiSets=(bondi bondi mbondi mbondi2 mbondi2 bondi mbondi3 mbondi mbondi2 mbondi2 bondi)
## radii types to simplify tleap runs
RadiiTypes=(bondi mbondi mbondi2 mbondi3)
ParmDir="Parms"
## IS-specific info
isCut="20"
isRgbmax="20"
isNrespa="2"
isExtdiel="78.5"
isDiel="78.5"
isRbornstat="1"  ## will give stats on effective radii
isSaltcon="0.025" ## approximate average molarity of Cl- counterions from explicit runs
                  ## see the SaltCon tab of the Calculations_Workspace.ods spreadsheet
isArad="11.4"
## Run-specific info
ParmSuffix=".parm7"
## Use these for real runs
MinSteps=10000
HeatSteps=20000
Heatwx=1000
EquilSteps=1000000
Equilwx=1000
ProdSteps=50000000
Prodwx=5000
## Use these for trouble-shooting setups
#MinSteps=10
#HeatSteps=20
#Heatwx=10
#EquilSteps=100
#Equilwx=10
#ProdSteps=500
#Prodwx=50


### information about the runs
# the number of runs to set up
NumberOfRuns=32
RunsStartNumber=1
# other info
MoleculeInputFilePath="../../../input"
NumberOfRunSteps=4
StepNames=(Minimization Heating Equilibration Production)
StepAbbreviations=(min heat equil prod)
InputFiles=(min.in heat.in equil.in prod.in)
AmberHome="/programs/amber14"
Executable="/programs/amber14/bin/sander"  ## pmemd will do a few igb's, but using sander for consistency in all
Path="\$AMBERHOME/bin:\$PATH:/usr/lib64/qt-3.3/bin:/usr/kerberos/bin:/programs/bin:/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:/opt/torque/bin"
LdLibPath="\$LD_LIBRARY_PATH:\$AMBERHOME/lib:/programs/lib:/usr/local/lib"
wallclock="Total time"


