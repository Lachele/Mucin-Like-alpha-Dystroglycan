GLYHOME = /programs/repos/GLYLIB
#GLYHOME = /programs/GLYLIB.git
GLYLIB = $(GLYHOME)/lib
GLYINC = $(GLYHOME)/inc
S1 = concatenate_rmsd.c
E1 = summarize_rmsds
S2 = concatenate_site-level_rmsd.c
E2 = summarize_site-specific_rmsds

default:
	gcc -Wall $(S1) -I$(GLYINC) -L$(GLYLIB) -g -lglylib -lm -o $(E1) 

sites:
	gcc -Wall $(S2) -I$(GLYINC) -L$(GLYLIB) -g -lglylib -lm -o $(E2) 
	
