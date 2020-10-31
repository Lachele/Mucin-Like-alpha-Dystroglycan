#GLYHOME = /programs/GLYLIB.git
GLYHOME = /programs/repos/GLYLIB
GLYLIB = $(GLYHOME)/lib
GLYINC = $(GLYHOME)/inc
S1 = Bin_PhiPsi_for_plots.c
E1 = bin_phipsi
S2 = Bin_PhiPsi_for_plots_2.c
E2 = bin_phipsi_2
S3 = Make_2d_ptraj_PhiPsi_bins.c
E3 = bin_phipsi_ptraj
S4 = Make_2D_bins_one_file.c
E4 = bin_two_columns

default:
	gcc -Wall $(S1) -I$(GLYINC) -L$(GLYLIB) -o $(E1) -lglylib -lm -g

IS:
	gcc -Wall $(S2) -I$(GLYINC) -L$(GLYLIB) -o $(E2) -lglylib -lm -g

ISptraj:
	gcc -Wall $(S3) -I$(GLYINC) -L$(GLYLIB) -o $(E3) -lglylib -lm -g

TwoCol:
	gcc -Wall $(S4) -I$(GLYINC) -L$(GLYLIB) -o $(E4) -lglylib -lm -g
