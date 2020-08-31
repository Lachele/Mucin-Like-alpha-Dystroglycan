GLYHOME = /programs/repos/GLYLIB
GLYLIB = $(GLYHOME)/lib
GLYINC = $(GLYHOME)/inc
S1 = remove_bad_coords.c
E1 = fix_coords

default:
	gcc -Wall $(S1) -I$(GLYINC) -L$(GLYLIB) -g -lglylib -lm -o $(E1) 

