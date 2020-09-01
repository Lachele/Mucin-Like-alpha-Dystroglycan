#include <glylib.h>

#define USAGE "\n\
      Usage:\n\
            extract_phi_psi Input_file \n\
\n\
      Where: \n\
\n\
            Input_file = file containing phi-psi data\n\
\n\
The program will assume: \n\
  - There are four sets of Phi-Psi values in columns 2-9 \n\
  - Lines beginning with a hash (#) are to be ignored \n\
  - No line is longer than 999 characters \n\
  - Output files go in subdirectory 2D_J-Coupling \n\
  - The subdirectory 2D_J-Coupling already exists \n\
  - The filename contains only one underscore followed by a t, a number and a period \n\
    and that the number is unique and not greater than 9999. \n\
  - Filenames will be also be binned in an NGxNG grid (see defines) \n\
The program will also: \n\
  - Name files as A_t where \n\
         A=4, 5, 6 or 7, to indicate the relevant THR residue \n\
         t=the run number from the file name \n\
  - Place the output files in a subdirectory 2D_J-Coupling \n\
  - Place binned output in the file BINS_A_t \n\
"
#define DIRECTORY_PREFIX "2D_J-Coupling/"
#define NG 36
#define InterpolateDATAMax 50000

int main(int argc, char *argv[])
{
int i=0,f=0,d1=0,d2=0,n=0,nmax[4],***GRID; /* amino acid position iterator */
fileset IN,OUT[4],BINS[4]; /* BINS = normalized to max value */
char *strtemp,tstring[100],line[1000];
double dtemp=0;

if(argc<2) mywhineusage("Incorrect number of arguments.",USAGE);

/* Open the input file */
IN.N=strdup(argv[1]);
IN.F=myfopen(IN.N,"r");

/* allocate grid space */
GRID=(int***)calloc(4, sizeof(int**));
for(i=0;i<4;i++)
	{
	GRID[i]=(int**)calloc(NG, sizeof(int*));
	for(f=0;f<NG;f++) GRID[i][f]=(int*)calloc(NG, sizeof(int));
	}

/* get value for t */
strtemp=(strstr(argv[1],"_t")+2);
i=0;
while (strtemp[0]!='.')
	{
//printf("strtemp is %c \n",strtemp[0]);
	tstring[i]=strtemp[0];
	strtemp++;
	i++;
	if(i>4) mywhineusage("value of t is too large",USAGE);
	}
tstring[i]='\0';
//printf("tstring is >>%s<<\n",tstring);

/* Generate output file names and open the input files */
for (i=0;i<4;i++)
	{
	OUT[i].N=(char*)calloc(strlen(tstring)+strlen(DIRECTORY_PREFIX)+3, sizeof(char));
	sprintf(OUT[i].N,"%s%d_%s",DIRECTORY_PREFIX,i+1,tstring);
	OUT[i].F=myfopen(OUT[i].N,"w"); 
	BINS[i].N=(char*)calloc(strlen(tstring)+strlen(DIRECTORY_PREFIX)+7, sizeof(char));
	sprintf(BINS[i].N,"%sBINS_%d_%s",DIRECTORY_PREFIX,i+1,tstring);
	BINS[i].F=myfopen(BINS[i].N,"w");
	nmax[i]=0;
	}

f=fscanf(IN.F,"%s",tstring);
n=0;
//printf("line is >>%s",line);
while (f!=EOF) 
	{
//printf("tstring is >>%s<<\n",tstring);
	if (tstring[0]!='#')
		{
		n++;
		for (i=0;i<4;i++)
			{
//printf("Set %d \n",i);
			f=fscanf(IN.F,"%s",tstring);
			fprintf(OUT[i].F,"%15s  ",tstring); 
			if(sscanf(tstring,"%lf",&dtemp)!=1) mywhine("problem reading tstring 1");
//printf("\ttstring=>>%s<< and dtemp=%f and next dtemp is",tstring,dtemp);
			/*  
			Uncomment this and comment the next to wrap 0 to 360 rather
				than -180 to 180
			if(dtemp<0) dtemp+=360.0;
			d1=floor((double)NG*dtemp/360.0);
			*/
			/* 
			The following method preserves the -180 to 180 scale, but
			moves things over for the array.
			*/
			d1=floor((double)NG*(180.0+dtemp)/360.0);
//printf(" %f and d1 is %d\n",dtemp,d1);
			f=fscanf(IN.F,"%s",tstring);
			fprintf(OUT[i].F,"%15s  \n",tstring);
			if(sscanf(tstring,"%lf",&dtemp)!=1) mywhine("problem reading tstring 1");
//printf("\ttstring=>>%s<< and dtemp=%f and next dtemp is",tstring,dtemp);
			/*  
			Uncomment this and comment the next to wrap 0 to 360 rather
				than -180 to 180
			if(dtemp<0) dtemp+=360.0;
			d2=floor((double)NG*dtemp/360.0);
			*/
			/* 
			The following method preserves the -180 to 180 scale, but
			moves things over for the array.
			*/
			d2=floor((double)NG*(180+dtemp)/360.0);
//printf(" %f and d2 is %d\n",dtemp,d1);
//printf("\t\tadding data to bin d1=%d d2=%d \n",d1,d2);
			GRID[i][d1][d2]++;
			if(GRID[i][d1][d2]>nmax[i]) nmax[i]=GRID[i][d1][d2];
			}
		}
	fgets(line,1000,IN.F); 
	f=fscanf(IN.F,"%s",tstring);
//printf("line is >>%s",line);
	}
if (n>InterpolateDATAMax) printf("Your data has more entries than the interpolation program expects.  Go change its code.\n");

for (i=0;i<4;i++) fclose(OUT[i].F);

for (i=0;i<4;i++) 
	{
	for (d2=0;d2<NG;d2++)
		{
		for (d1=0;d1<NG;d1++)
			{
			fprintf(BINS[i].F,"%10.5f ",(double)GRID[i][d1][d2]/(double)nmax[i]);
			}
		fprintf(BINS[i].F,"\n");
		}
	}
for (i=0;i<4;i++) fclose(BINS[i].F);


return 0;
}
