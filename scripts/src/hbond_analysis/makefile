GLYHOME = /e05/lachele/software/GLYLIB_working
#GLYHOME = /programs/repo/GLYLIB
#GLYHOME = /programs/GLYLIB.git
GLYLIB = $(GLYHOME)/lib
GLYINC = $(GLYHOME)/inc
S1 = do_hbond_analysis.c
E1 = hbond_analysis
S2 = Make_hbond_bins.c
E2 = makeHbondBins
S3 = do_GalNAc_analysis.c
E3 = GalNAc_analysis
S4 = test_top.c
E4 = toptest
S5 = do_equil_water_check.c
E5 = bridgecheck

default:
	gcc -Wall $(S1) -I$(GLYINC) -L$(GLYLIB) -g -lglylib -lm -o $(E1) 

HBins:
	gcc -Wall $(S2) -I$(GLYINC) -L$(GLYLIB) -g -lglylib -lm -o $(E2) 

GalNAc:
	gcc -Wall $(S3) -I$(GLYINC) -L$(GLYLIB) -g -lglylib -lm -o $(E3) 

test:
	gcc -Wall $(S4) -I$(GLYINC) -L$(GLYLIB) -g -lglylib -lm -o $(E4) 

bridge:
	gcc -Wall $(S5) -I$(GLYINC) -L$(GLYLIB) -g -lglylib -lm -o $(E5) 
