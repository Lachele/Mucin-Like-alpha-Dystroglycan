#include "glylib.h"
#define USAGE "\n\
	makeMDBins Bin_file Prefix Field Num_sets \n\
\n\
where: \n\
	Bin_file \n\
	    contains the values you want to make quant plots for. \n\
	    The numbers can be anywhere in a line, as many times per \n\
	    line as you like. They must be in the form:\n\
	            KEYWORD SEPARATOR VALUE \n\
	    for example...\n\
	            Etot = 1.557 \n\
	            Uptime : 30992 \n\
	    For faster file reads, having less superfluous info is good.\n\
            You might grep sander output for the keyword.  Just be sure to\n\
            leave out RMS values and any final overall averages.\n\
            For example:\n\
                    grep -A10 \"A V E R A G E S   O V E R     100 S T E P S\" sander.out | grep Etot > Binfile\n\
            Alternately, you can use output from ptraj as your bin file.\n\
            If you do that, then for Field, use \"ptraj\".\n\
\n\
	Field is the measured thing you want to bin (Etot, here). \n\
	Num_Sets is the maximum number of sub-sets for dividing the data \n\
            Num_Sets need not be a factor of the number of points.  If not,\n\
            bins at the edges might not be good population representations\n\
\n"

/*  the repeating unit:  *//*
      A V E R A G E S   O V E R     100 S T E P S


 NSTEP =      100   TIME(PS) =    1050.200  TEMP(K) =   294.82  PRESS =  -288.2
 Etot   =     -5200.9716  EKtot   =      1271.3443  EPtot      =     -6472.3159
 BOND   =        11.8908  ANGLE   =        28.0053  DIHED      =        12.1743
 1-4 NB =         8.8215  1-4 EEL =       439.4164  VDWAALS    =       946.3831
 EELEC  =     -7919.0072  EHBOND  =         0.0000  RESTRAINT  =         0.0000
 EKCMT  =       623.5878  VIRIAL  =       759.0120  VOLUME     =     21767.5408
                                                    Density    =         0.9950
 Ewald error estimate:   0.2712E-03
-- 
*/


/***************************  main() *******************************/
int main(int argc, char *argv[]){
int bins,*BIN,npts,i,useptraj=1;
double widthtot,binwidth,*PTS,maxp=0,minp=0,checkmax=1;
FILE *IF,*OF;
char temp[250];

/* Check input for sanity */
if ( argc != 5 )	{
		mywhineusage("Incorrect number of arguments.", USAGE); }

/* Here, npts is just being used as a dummy variable */
npts		=	sscanf( argv[4], "%d", &bins);
if( npts != 1 )		mywhineusage ("Num_sets appears not to be an integer.", USAGE);
BIN		=	(int*) calloc ( bins, sizeof(int) );

IF		=	myfopen( argv[1], "r" ); 
/* set some values per type of file we expect */
if ( strcmp(argv[3],"ptraj")==0 )  { useptraj	=	0; }
/* Figure out how much space we need */
if ( useptraj == 0 ) 	npts	=	cscan_file( IF, '\n' );
else 			npts	=	sscan_file( IF, argv[3] );
PTS	=	(double*) calloc (npts, sizeof(double));
printf("argv[3] is %s and useptraj is %d and npts is %d\n",argv[3],useptraj,npts);
rewind(IF);

if ( useptraj == 0 )
        {
	if(fgets(temp,249,IF)==NULL) 	mywhine("problem reading Bin_file 0"); 
	npts--;
	}
i=0;
while(i<npts)
  {
  if(fscanf(IF,"%s",temp)==EOF) 	break; 
  checkmax=1;
//printf("temp (top) is >>%s<<\n",temp);
  if ( useptraj == 0 ) 
	{
	if(fscanf(IF,"%lf",&PTS[i])!=1) 
		{
//printf("PTS[%d] is >>%f<<\n",i,PTS[i]);
		mywhine("problem reading Bin_file 1");
		}
	i++;
	checkmax=0;
	}
  else 
	{
	if(strcmp(temp,argv[3])==0)
		{ 
//printf("temp is %s after \n",temp);
		if(fscanf(IF,"%s",temp)!=1) 	mywhine("problem reading Bin_file 2");
		if(fscanf(IF,"%lf",&PTS[i])!=1) 	mywhine("problem reading Bin_file 3");
//printf("temp is %s and PTS[i=%d] is %f\n",temp,i,PTS[i]);
		i++;
		checkmax=0;
		}
	}
  if(checkmax==0)
	{
  	if((i-1)==0) 	maxp=minp=PTS[0];
	if(minp>PTS[i-1])			minp=PTS[i-1];
	if(maxp<PTS[i-1])			maxp=PTS[i-1];
//if(maxp==0) printf("maxp is zero at i-1=%d and PTS[i-1]=%f with PTS[i-2]=%f \n",i-1,PTS[i-1],PTS[i-2]);
	}
  }

widthtot	=	(double)(maxp-minp);
binwidth	=	widthtot/(double)bins;
printf("npts = %d minp = %f   maxp = %f   widthtot = %f   binwidth = %f \n",npts,minp,maxp,widthtot,binwidth);

printf("1\n");
for(i=0;i<npts;i++) 
	{ 
//printf("PTS[i] is %f ; minp is %f ; binwidth is % f; the bin is %d \n",PTS[i],minp,binwidth,(int)( (PTS[i]-minp) / binwidth ) );
	BIN[ (int)( (PTS[i]-minp) / binwidth ) ]++; 
	}

printf("2\n");
sprintf(temp,"%s_bins.txt",argv[2]);
printf("3\n");
OF		=	myfopen(temp,"w");
printf("4\n");
fprintf(OF,"#Bin Center\tCount\n");
printf("5\n");
for(i=0;i<bins;i++) fprintf(OF,"%g\t%d\n",(minp+0.5*(2*i+1)*binwidth),BIN[i]);
printf("6\n");

return 0;
}
