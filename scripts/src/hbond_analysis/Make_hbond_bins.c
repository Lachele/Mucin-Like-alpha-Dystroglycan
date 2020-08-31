#include "glylib.h"
#define USAGE "\n\
	makeHbondBins Num_sets \n\
\n\
where: \n\
	Num_sets \n\
	    is the number of simulations in this runset. \n\
\n\
            This program really only works with this set of simulations\n\
            See comments in code for details.\n\
\n"

/*  the repeating unit:  *//*

This code should be run from the runset/ANALYSIS directory.  It assumes
subdirectories called HBOND and DIST.  

In DIST, there should be a file:      Distances_N-N.dat_ALL

In HBOND, there should be a series of files called:

	LENGTH_DETAILS_*_HBond_details.txt

... where * represents the zero-padded 4-digit integers from 1 to Num_sets.

It will generate files called:

	All_SIM_Bins.txt
		Bin information for the entire simulation
	BOND_*_Bins.txt
		Contains data binned for 150 divisions from 5-35 Angstroms.
	BOND_*_Normal_Bins.txt
		that will contained ratioed and normalized bins of lengths for each HBond.

It will also produce a summary file:

	All_Bonds_Normalized_Bins.txt

This file will contain various information about the bonds' bins.

See also my ELN for more info:

http://128.192.9.183/eln/lachele/2013/07/02/new-plan-for-hbond-analysis/
*/

#define NUMBINS 140
#define MINP      2.0
#define MAXP     16.0
#define CompMin  11.0
#define CompMax  14.0
#define CompSteps  3
#define AllNNFileName "DIST/Distances_N-N.dat_ALL"
#define AllNNOutFileName "DIST/All_SIM_Bins.txt"
#define BFileInPrefix "HBOND/LENGTH_DETAILS_HB_"
#define BFileInSuffix ".txt"
#define BFileOutPrefix "HBOND/BOND_"
#define BFileOutSuffix "_Bins.txt"
#define ComparisonFileName "HBOND/BOND_comparisons.txt"

/***************************  main() *******************************/
int main(int argc, char *argv[]){
int 	*NBIN, /**< Bins for overall N-N length */
	*BBIN, /**< Bins for H-Bonds at N-N length */
	Npts=0, /**< Number of points in the overall set */
	Bpts=0, /**< number of points in the H-bond set */
	Nmax=0, /**< Number of points in the overall set */
	Bmax=0, /**< number of points in the H-bond set */
	NumSets=0, /**< Number of H-Bonds to consider */
	k,
	j,
	i;
double Nval,Bval,binwidth,RatioTemp,compwidth,midpoint;
double *NCOMP,normratio; /**< Array for keeping up with the Normal-Ratioed comparison */
fileset	NF, /**< contains the overall sim N-N length data */
 	BF, /**< will change during execution, contains H-bond specific length data */
 	CF, /**< comparison file name */
	OFN, /**< output file for All-sim NN bins */
	OF; /**< variable for output file information */
char temp[250];

/* Check input for sanity */
if ( argc != 2 )   mywhineusage("Incorrect number of arguments.", USAGE); 
if ( sscanf(argv[1],"%d",&NumSets) != 1 ) mywhineusage("Can't get Num_Sets",USAGE);

CF.N=strdup(ComparisonFileName);
NF.N=strdup(AllNNFileName);
OFN.N=strdup(AllNNOutFileName);
BF.N=(char*)calloc(strlen(BFileInPrefix)+strlen(BFileInSuffix)+5,sizeof(char));
OF.N=(char*)calloc(strlen(BFileOutPrefix)+strlen(BFileOutSuffix)+5,sizeof(char));

compwidth	= 	( CompMax - CompMin ) / (double) CompSteps ;
NCOMP=(double*)calloc(CompSteps,sizeof(double));
binwidth	= 	( MAXP - MINP ) / (double) NUMBINS ;
NBIN=(int*)calloc(NUMBINS,sizeof(int));
BBIN=(int*)calloc(NUMBINS,sizeof(int));

/* Get the over-all-simulations distribution of N-N lengths */
NF.F = myfopen(NF.N,"r");
Nmax=0;
Npts=0;
while(fgets(temp,249,NF.F)!=NULL)
	{
	if(temp[0]=='#') 	continue; 
	sscanf(temp,"%lf %lf",&Bval,&Nval); /* tossing Bval here */
	if((Nval<MINP)||(Nval>MAXP)) mywhine("Nval out of range");
	i = (int) ( ( Nval - MINP ) / binwidth );
	NBIN [ i ]++;
	if(NBIN[i] > Nmax) Nmax=NBIN[i];
	Npts++;
	}

/* Print the over-all-simulations distribution of N-N lengths */
OFN.F=myfopen(OFN.N,"w");
fprintf(OFN.F,"# %10s %10s %10s %10s\n","Midpoint","Counts","Scaled","Normal");
for(i=0;i<NUMBINS;i++)
	{
	fprintf(OFN.F," %10.2f %10d %10.6f %10.6f\n",MINP+0.5*(2*i+1)*binwidth,\
		NBIN[i],NBIN[i]/(double)Nmax,NBIN[i]/(double)Npts);
	}
fclose(OFN.F);

CF.F=myfopen(CF.N,"w");
fprintf(CF.F,"# Sums of the ratioed-normal distributions for the indicated ranges\n# Index");
for(j=0;j<CompSteps;j++) 
	{
	fprintf(CF.F," %5.2f - %5.2f ",CompMin+(j*compwidth),CompMin+((j+1)*compwidth));
	}
fprintf(CF.F,"  Bpts      EndsDiff \n");

/* For each H-Bond input file */
for(j=0;j<NumSets;j++)
	{
	/* Get the H-Bond specific distribution of N-N lengths */
	Bpts=Bmax=0;
	sprintf(BF.N,"%s%04d%s",BFileInPrefix,j+1,BFileInSuffix);
	BF.F = myfopen(BF.N,"r");
	while(fgets(temp,249,BF.F)!=NULL)
		{
		if(temp[0]=='#') 	continue; 
		Bpts++;
		sscanf(temp,"%lf %lf %lf %lf %lf %lf %lf",\
			&Nval,&Nval,&Nval,&Nval,&Nval,&Nval,&Bval); /* tossing Nval here */
		if((Bval<MINP)||(Bval>MAXP)) mywhine("Bval out of range");
		i = (int) ( ( Bval - MINP ) / binwidth );
		BBIN [ i ]++;
		if(BBIN[i] > Bmax) Bmax=BBIN[i];
		}
	fclose(BF.F);

	if(Bpts==0) mywhine("Bpts is zero!");
	if(Bmax==0) mywhine("Bmax is zero!");
//printf("Bpts is %d and Bmax is %d\n",Bpts,Bmax);
	
	/* Print the over-all-simulations distribution of N-N lengths */
	sprintf(OF.N,"%s%04d%s",BFileOutPrefix,j+1,BFileOutSuffix);
	OF.F=myfopen(OF.N,"w");
	fprintf(OF.F,"# %10s %10s %10s %10s %10s %10s %10s\n","Midpoint",\
		"Counts","Scaled","Normal","Ratioed","RScaled","RNormal");
	for(i=0;i<NUMBINS;i++)
		{
		if(BBIN[i]==0) RatioTemp=0;
		else 
			{
			if(NBIN[i]<BBIN[i]) mywhine("NBIN[i] cannot be less than BBIN[i]");
			RatioTemp=(double)BBIN[i]/(double)NBIN[i];
			}
		midpoint=MINP+0.5*(2*i+1)*binwidth;
		normratio=RatioTemp*(double)Npts/(double)Bpts;
		fprintf(OF.F," %10.2f %10d %10.6f %10.6f %10.6f %10.6f %10.6f\n",midpoint,\
			BBIN[i],\
			BBIN[i]/(double)Bmax,\
			BBIN[i]/(double)Bpts,\
			RatioTemp,\
			RatioTemp*(double)Nmax/(double)Bmax,\
			normratio);
		if((midpoint>CompMin)&&(midpoint<CompMax))
			{
			k = (int) ( (midpoint - CompMin) / compwidth );
			NCOMP[k]+=normratio;
			}
		}
	fclose(OF.F);

	fprintf(CF.F,"%7d",j+1);
	for(k=0;k<CompSteps;k++) fprintf(CF.F,"%15.4f",NCOMP[k]);
	fprintf(CF.F,"%10d%15.4f\n",Bpts,NCOMP[CompSteps-1]-NCOMP[0]);
	
	for(i=0;i<NUMBINS;i++) BBIN[i]=0;
	for(k=0;k<CompSteps;k++) NCOMP[k]=0;
	}

return 0;
}
