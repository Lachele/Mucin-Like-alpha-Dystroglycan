#include "glylib.h"
#include <float.h>
#define USAGE "\n\
	make2d_bins_onefile InputFile \n\
\n\
where: \n\
	InputFile \n\
            The file format should be similar to output from cpptraj.\n\
            This file should contain both columns of data to be binned.\n\
\n\
	    Contents of InputFile: \n\
\n\
                Keyword = Value pairs for these keywords: \n\
                          One pair per line. \n\
\n\
	                  Data_File \n\
	                  Output_File \n\
	                  Num_Bins \n\
	                  First_Col \n\
	                  First_Min \n\
	                  First_Max \n\
	                  Second_Col \n\
	                  Second_Min \n\
	                  Second_Max \n\
\n"

/***************************  main() *******************************/
int main(int argc, char *argv[]){
int First_Col,Second_Col;
int bins,**BIN,nlines,npts,f,i,j,d1,d2,nmax=0,NSq;
double NormN,tmpPT1,tmpPT2;
double *PTS1,*PTS2;
double maxp1=-DBL_MAX,minp1=DBL_MAX,maxp2=-DBL_MAX,minp2=DBL_MAX;
double First_Max,First_Min,Second_Max,Second_Min;
double Range1=0,Range2=0,cntr1=0,cntr2=0;
fileset IF,DF,OF;
gly_keysvals Options;
char OutOfBounds,tstring[100],line[1000];

/* Check input for sanity */
if ( argc != 2 )	{
		mywhineusage("Incorrect number of arguments.", USAGE); }

/* Read the input file */
IF.N	=	strdup( argv[1] );
IF.F	=	myfopen( argv[1], "r" ); 
Options	=	get_keysvals_from_file(IF,"=",0,0);
fclose(IF.F);

for(i=0;i<Options.n;i++)
{
	if(strcmp(Options.K[i],"Data_File")==0)	
	{
		DF.N	=	strdup(Options.V[i]);
		DF.F	=	myfopen( DF.N, "r" ); 
	}
	if(strcmp(Options.K[i],"Output_File")==0)
	{
		OF.N	=	strdup(Options.V[i]);
		OF.F	=	myfopen( OF.N, "w" ); 
	}
	if(strcmp(Options.K[i],"Num_Bins")==0)
	{
		j	=	sscanf(Options.V[i],"%d",&bins);
		if( j != 1 )	mywhineusage ("Num_Bins appears not to be an integer.", USAGE);
	}
	if(strcmp(Options.K[i],"First_Col")==0)
	{
		j	=	sscanf(Options.V[i],"%d",&First_Col);
		if( j != 1 )	mywhineusage ("First_Col appears not to be an integer.", USAGE);
	}
	if(strcmp(Options.K[i],"First_Min")==0)
	{
		j	=	sscanf(Options.V[i],"%lf",&First_Min);
		if( j != 1 )	mywhineusage ("First_Min appears not to be a number.", USAGE);
	}
	if(strcmp(Options.K[i],"First_Max")==0)
	{
		j	=	sscanf(Options.V[i],"%lf",&First_Max);
		if( j != 1 )	mywhineusage ("First_Max appears not to be a number.", USAGE);
	}
	if(strcmp(Options.K[i],"Second_Col")==0)
	{
		j	=	sscanf(Options.V[i],"%d",&Second_Col);
		if( j != 1 )	mywhineusage ("Second_Col appears not to be an integer.", USAGE);
	}
	if(strcmp(Options.K[i],"Second_Min")==0)
	{
		j	=	sscanf(Options.V[i],"%lf",&Second_Min);
		if( j != 1 )	mywhineusage ("Second_Min appears not to be a number.", USAGE);
	}
	if(strcmp(Options.K[i],"Second_Max")==0)
	{
		j	=	sscanf(Options.V[i],"%lf",&Second_Max);
		if( j != 1 )	mywhineusage ("Second_Max appears not to be a number.", USAGE);
	}
}

if(First_Col<=0) mywhineusage("First_Col cannot be less than or equal to 0",USAGE);
if(First_Col>=Second_Col) mywhineusage("Second_Col cannot be less than or equal to First_Col",USAGE);
if(First_Max<First_Min) mywhineusage("First_Min must be less than First_Max",USAGE);
if(Second_Max<Second_Min) mywhineusage("Second_Min must be less than Second_Max",USAGE);

BIN		=	(int**) calloc ( bins, sizeof(int*) );
for(i=0;i<bins;i++) BIN[i]=(int*)calloc(bins,sizeof(int));

/* Figure out how much space we need */
nlines	=	cscan_file( DF.F, '\n' );
printf("Found %d lines in the file - this might be more than the number of points\n",nlines);
PTS1	=	(double*) calloc (nlines, sizeof(double));
PTS2	=	(double*) calloc (nlines, sizeof(double));
rewind(DF.F);

/* see if this is the first line of the file */
tstring[0]='\0';
f=fscanf(DF.F,"%s",tstring);
//printf("line is >>%s",line);
npts=0;
while (f!=EOF) 
	{
//printf("tstring is >>%s<<\n",tstring);
	if (tstring[0]!='#') /* if this is not a comment line */
		{
		for(i=1;i<First_Col;i++)
			{
			f=fscanf(DF.F,"%s",tstring);
			if(f!=1) mywhine("problem reading file before First_Col.");
			}
		f=sscanf(tstring,"%lf", &tmpPT1);
		if(f!=1) mywhine("problem reading data for First_Col.");
		for(i=i;i<Second_Col;i++)
			{
			f=fscanf(DF.F,"%s",tstring);
			if(f!=1) mywhine("problem reading file before Second_Col.");
			}
		f=sscanf(tstring,"%lf", &tmpPT2);
		if(f!=1) mywhine("problem reading data for Second_Col.");
		OutOfBounds='n';
		if ( (tmpPT1<First_Min) || (tmpPT1>First_Max) ) OutOfBounds='y';
		if ( (tmpPT2<Second_Min) || (tmpPT2>Second_Max) ) OutOfBounds='y';
		if ( OutOfBounds=='n' ) {
			PTS1[npts]=tmpPT1;
			PTS2[npts]=tmpPT2;
			npts++;
		}
		}
		fgets(line,1000,DF.F); 
		f=fscanf(DF.F,"%s",tstring);
//printf("line is >>%s",line);
//fflush(stdout);
	}
fclose(DF.F);
printf("Found %d data pairs inside the requested range.\n",npts);

printf("1\n");
Range1=First_Max-First_Min;
Range2=Second_Max-Second_Min;
printf("Range 1 is %f and Range 2 is %f\n",Range1,Range2);
nmax=0;
for(i=0;i<npts;i++) 
	{ 
	if(minp1>PTS1[i])	minp1=PTS1[i];
	if(maxp1<PTS1[i])	maxp1=PTS1[i];
	if(minp2>PTS2[i])	minp2=PTS2[i];
	if(maxp2<PTS2[i])	maxp2=PTS2[i];
	d1=floor((double)bins*(PTS1[i]-First_Min)/Range1);
	d2=floor((double)bins*(PTS2[i]-Second_Min)/Range2);
	BIN[d1][d2]++; 
	if ( BIN[d1][d2] > nmax ) nmax = BIN[d1][d2];
	}

printf("2\n");
fprintf(OF.F,"#Bin1\tBin2\tover npts\tover nmax\tCounts\tmax1000\tover sqrtnpts\n");
NSq=0;
for(i=0;i<bins;i++) {
  	for(j=0;j<bins;j++) {
		NSq+=(BIN[i][j]*BIN[i][j]);
		}
	}
NormN=sqrt((double)NSq);
for(i=0;i<bins;i++) 
  {
  cntr1	=	First_Min+((i+0.5)*Range1/(double)bins);
//  printf("cntr1 is %f\n",cntr1);
  for(j=0;j<bins;j++) 
    {
    cntr2	=	Second_Min+((j+0.5)*Range2/(double)bins);
//    printf("    cntr2 is %f\n",cntr2);
    if(BIN[i][j]>NormN) printf("count (%d) in BIN[%d][%d] is larger than NormN (%.2f)\n",BIN[i][j],i,j,NormN);
    fprintf(OF.F,"%g\t%g\t%10.5f\t%10.5f\t%d\t%10.0f\t%10.5f\n",cntr1,cntr2,(double)BIN[i][j]/npts,(double)BIN[i][j]/nmax,BIN[i][j],1000*(double)BIN[i][j]/nmax,(double)BIN[i][j]/NormN);
    }
    fprintf(OF.F,"\n");
  }

return 0;
}
