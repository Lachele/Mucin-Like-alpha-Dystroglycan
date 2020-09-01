#!/bin/bash

#PBS -q md
#PBS -l nodes=1:ppn=26
#PBS -N d4m_26

cd $PBS_O_WORKDIR

bash ./RunAll_26.sh
