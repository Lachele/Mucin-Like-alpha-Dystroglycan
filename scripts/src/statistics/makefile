GLYLIB = /programs/repos/GLYLIB/lib
GLYINC = /programs/repos/GLYLIB/inc
CFLAGS = -Wall -I$(GLYINC) -L$(GLYLIB) -lglylib -lm

SDM:
	gcc check_SDM_general.c -o getSDMInfo $(CFLAGS) -g

Bins:
	gcc Make_bins.c -o makeMDBins $(CFLAGS) -g

2D:
	gcc Make_2d_ptraj_bins.c -o make2Dbins $(CFLAGS) -g

2Dcpp:
	gcc Make_2d_cpptraj_bins.c -o make2Dcppbins $(CFLAGS) -g
