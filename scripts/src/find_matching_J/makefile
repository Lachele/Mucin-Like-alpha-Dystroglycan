GLYHOME = /programs/repos/GLYLIB
GLYLIB = $(GLYHOME)/lib
GLYINC = $(GLYHOME)/inc
S1 = find_points_in_J_range.c
E1 = get_J_points

default:
	gcc -Wall $(S1) -I$(GLYINC) -L$(GLYLIB) -g -lglylib -lm -o $(E1) 

