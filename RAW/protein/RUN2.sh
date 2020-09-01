#!/bin/bash

# Submit a serial pmemd job

export AMBERHOME=/programs/gpu/amber12
export PATH=/programs/amber12/bin:/programs/local/bin:/programs/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:./:/opt/torque/bin:/programs/gpu/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin
export LD_LIBRARY_PATH=/programs/local/lib:/programs/lib:/usr/local/lib:::/programs/gpu/lib:/usr/local/lib64:/usr/local/lib:/lib64:/lib:/usr/lib64:/usr/lib


#
# Production 2
#
/programs/gpu/amber12/bin/pmemd \
 -p input.parm7 \
 -c prod.rst7 \
 -i ../../prod_protein2.in \
 -o prod2.o \
 -r prod2.rst7 \
 -x prod2.nc \
 -inf prod2.info \
 -l prod2.log 
#


