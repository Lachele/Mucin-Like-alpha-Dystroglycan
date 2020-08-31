#include <glylib.h>

#define USAGE "\n\
      Usage:\n\
            make_rmsd_matrices num_trajectories num_init \n\
\n\
      Where: \n\
\n\
            num_runs = the number of trajectoriesuns \n\
            num_init = the number of initial structures \n\
\n\
The program will assume among other things: \n\
  - Input files are named: \n\
         Back_prod_rmsd_t*_r-all.dat and \n\
         Sugr_prod_rmsd_t*_r-all.dat  \n\
  - Input files have initial structure in each column, except the first \n\
         (which is an index), and trajectory snapshots in each row.\n\
  - Input files are in the current working directory \n\
  - If the number of trajectories is different from the number of initial structures: \n\
         - num_trajectories/num_init is a whole number \n\
         - traj numbers 1 to num_init are set 1, num_init+1 to 2*num_init are set 2 etc. \n\
  - Matrix files go in subdirectory MATRICES \n\
  - Summary files go in subdirectory SUMMARIES \n\
"

int main(int argc, char *argv[])
{
int t=0, /* trajectory iterator */
    i=0, /* initial structure iterator */
    nT=0, /* number of trajectories */
    nI=0, /* number of initial structures */
    nTperI=0; /* number of traj per init struct */
double  
        **RMSavgB, /* RMSavg[init struct][traj] */
        **RMSstdB, /* RMSstd[init struct][traj] */
        **RMSavgS, /* RMSavg[init struct][traj] */
        **RMSstdS; /* RMSstd[init struct][traj] */
statsarray *TSdataB, *TSdataS; /* temporary array for keeping trajectory data per each init struct */
meanvar *TStatsB, *TStatsS; /* place to store the results of get_meanvar_array */
fileset 
        /* for the backbone relevant to the THR residues */
        *InB,    /* nT individual input files containing most of the TFB information */
        *TFB,    /* nT individual matrices of trajectory (Y) versus initial structure (X) */
        *IFB,    /* nI individual matrices of initial structure (Y) versus trajectory (X) */
         TallFB,    /* All nT matrices, one file, with separator, of trajectory (Y) versus initial structure (X) */
         IallFB,    /* All nI matrices, one file, with separator, of initial structure (Y) versus trajectory (Y) */
         ITavgB,   /* Summaries of average/stdev RMDS each trajectory versus initial structure(s) */
         ITMatavgB,   /* Matrix summary of average RMDS each trajectory versus initial structure(s) */
        /* for the heavy sugar atoms */
        *InS,    /* nT individual input files containing most of the TFB information */
        *TFS,    /* nT individual matrices of trajectory (Y) versus initial structure (X) */
        *IFS,    /* nI individual matrices of initial structure (Y) versus trajectory (X) */
         TallFS,    /* All nT matrices, one file, with separator, of trajectory (Y) versus initial structure (X) */
         IallFS,    /* All nI matrices, one file, with separator, of initial structure (Y) versus trajectory (Y) */
         ITavgS,   /* Summaries of average/stdev RMDS each trajectory versus initial structure(s) */
         ITMatavgS;   /* Matrix summary of average RMDS each trajectory versus initial structure(s) */

if(argc<3) mywhineusage("Incorrect number of arguments.",USAGE);

/* Calculate the number of trajectories per initial structure */
sscanf(argv[1],"%d",&nT);
sscanf(argv[2],"%d",&nI);
if(nT%nI!=0) mywhineusage("nT/nI is not a whole number",USAGE);
nTperI=nT/nI; 

/*  
    This is not the most efficient method, but it is the method I am
    most likely not to screw up.
*/

/* Open all the input files */

/* Open some output files */
    /* Open B file for all Traj vs Init matrices */
    /* Open S file for all Traj vs Init matrices */
/* Loop over trajectories */
    /* Open one of the nT individual trajectory matrix files */
        /* For the THR Backbone atoms */
        /* For the Sugar heavy atoms */
    /* Print matrix stuff to the individual file and to the cumulative file */
    /* During this, be collecting data to get average, stdev */
        /* Add M lines to the cumulative file */ 
    /* Close the individual output files */
    /* Run get_menavar_array for stats summary and add results to RMSavg and RMSstd*/
    /* Clear the temporary array info */

/* Rewind all the input files */

/* Open more output files */
    /* For the THR Backbone atoms */
        /* Open nI individual initial structure matrix files */
        /* Open file for all Init vs Traj matrices */
    /* For the Sugar heavy atoms */
        /* Open nI individual initial structure matrix files */
        /* Open file for all Init vs Traj matrices */
/* Loop over initial structure */
    /* Loop over trajectory set */
        /* Loop over trajectory */

/* Open more output files */
    /* For the THR Backbone atoms */
        /* Open the big file for avg/stdev RMSD each traj vs init */
    /* For the Sugar heavy atoms */
        /* Open the big file for avg/stdev RMSD each traj vs init */

/* Open more output files */
    /* For the THR Backbone atoms */
        /* Open the big matrix file for avg RMSD each traj vs init */
    /* For the Sugar heavy atoms */
        /* Open the big matrix file for avg RMSD each traj vs init */


return 0;
}
