GLYHOME = /programs/repos/GLYLIB
GLYLIB = $(GLYHOME)/lib
GLYINC = $(GLYHOME)/inc
S1 = collect_rmsds.c
S2 = extract_psi-phi.c
E1 = make_rmsd_matrices
E2 = make_phi-psi_files

default:
	echo "no default defined.  choose a build."

rmsd:
	gcc -Wall $(S1) -I$(GLYINC) -L$(GLYLIB) -o $(E1) -lglylib -lm 

extract:
	gcc -Wall $(S2) -I$(GLYINC) -L$(GLYLIB) -o $(E2) -lglylib -lm 

