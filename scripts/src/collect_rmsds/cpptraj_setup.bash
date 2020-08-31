#!/bin/bash

# This is the setup file for making cpptraj input files for analyzing all the
# data from these runs. 

## First, indicate which run this is
#
IAM="0VA"  	# 0VA is glycam-speak for alpha-D-galnac

## Now, some info about the runs
MAXRUNS=32  	# The total number of simulations performed 
SETS=2   	# How many duplicate sets?  
SETSIZE=16	# How large was each set (should be MAXRUNS/SETS)


