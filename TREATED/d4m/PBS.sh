#!/bin/bash

#PBS -q md
#PBS -l nodes=1:ppn=32
#PBS -N d4m_32

cd $PBS_O_WORKDIR

bash RunAll.sh
