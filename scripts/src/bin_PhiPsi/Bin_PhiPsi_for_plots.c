#include <glylib.h>

#define USAGE "\n\
      Usage:\n\
            bin_phipsi P|S MaxRuns nGrid\n\
\n\
      Where: \n\
            P or S is required, and they are mutually exclusive.\n\
               They stand for Protein or Sugar.\n\
\n\
            MaxRuns is required - it is the number of runs to scan.\n\
\n\
            nGrid is required - it is the number of grid spaces.\n\
\n\
      CALL FROM: \n\
\n\
            call me from ANALYSIS \n\
\n\
The program will: \n\
  - Read in all the relevant files in the ANALYSIS/ANGLES directory \n\
  - Ignore lines beginning with a hash (#) \n\
  - Place output files in subdirectory PhiPsi_Bins \n\
  - The subdirectory PhiPsi_Bins already exists \n\
  - Assume standardized filenames similar to: \n\
       PhiPsi_t10.dat \n\
  - 2D bins with NGxNG divisions (see defines) \n\
"
#define INPUT_PREFIX "ANGLES/PhiPsi_t"
#define OUTPUT_PREFIX "PhiPsi_Bins/"

int main(int argc, char *argv[])
{
int i=0,t=0,f=0,d1=0,d2=0,n=0,nmax[4],***GRID; /* amino acid position iterator */
fileset IN,CONT_XYZ[4]; /* IMP_MATRIX is normd to max value; CONT to total n */
/* taking out */
fileset IMP_MATRIX[4],INT_MATRIX[4];
/* for now */
char tstring[100],line[1000];
double dtemp=0,d1_val,d2_val,testd1,testd2;
int MAXRUNS=-1,NG=-1;

if(argc<4) mywhineusage("Incorrect number of arguments.",USAGE);

sscanf(argv[2],"%d",&MAXRUNS);
if(MAXRUNS<0) mywhine("Something went wrong scanning max runs.");

sscanf(argv[3],"%d",&NG);
if(MAXRUNS<0) mywhine("Something went wrong scanning n grid.");

/* allocate grid space */
GRID=(int***)calloc(4, sizeof(int**));
for(i=0;i<4;i++)
	{
	GRID[i]=(int**)calloc(NG, sizeof(int*));
	for(f=0;f<NG;f++) GRID[i][f]=(int*)calloc(NG, sizeof(int));
	}

/* Generate output file names and open the input files */
for (i=0;i<4;i++)
	{
/* */
	IMP_MATRIX[i].N=(char*)calloc(strlen(OUTPUT_PREFIX)+7+strlen(argv[1]), sizeof(char));
	sprintf(IMP_MATRIX[i].N,"%s%s_IMP_%d",OUTPUT_PREFIX,argv[1],i+1);
	IMP_MATRIX[i].F=myfopen(IMP_MATRIX[i].N,"w");

	INT_MATRIX[i].N=(char*)calloc(strlen(OUTPUT_PREFIX)+7+strlen(argv[1]), sizeof(char));
	sprintf(INT_MATRIX[i].N,"%s%s_INT_%d",OUTPUT_PREFIX,argv[1],i+1);
	INT_MATRIX[i].F=myfopen(INT_MATRIX[i].N,"w");
/* */
	nmax[i]=0;
	CONT_XYZ[i].N=(char*)calloc(strlen(OUTPUT_PREFIX)+8+strlen(argv[1]), sizeof(char));
	sprintf(CONT_XYZ[i].N,"%s%s_CONT_%d",OUTPUT_PREFIX,argv[1],i+1);
	CONT_XYZ[i].F=myfopen(CONT_XYZ[i].N,"w");
	}

n=0;
IN.N=(char*)calloc(strlen(INPUT_PREFIX)+7,sizeof(char));
for(t=0;t<MAXRUNS;t++)
	{
	/* Open the input file */
	sprintf(IN.N,"%s%d.dat",INPUT_PREFIX,t+1);
	IN.F=myfopen(IN.N,"r");
	/* see if this is the first line of the file */
	tstring[0]='\0';
	f=fscanf(IN.F,"%s",tstring);
//printf("line is >>%s",line);
	while (f!=EOF) 
		{
//printf("tstring is >>%s<<\n",tstring);
		if (tstring[0]!='#') /* if this is not a comment line */
			{
			n++;
			if(argv[1][0]=='S') /* if we want sugar data */
				{
				for(i=0;i<8;i++)
					{
					f=fscanf(IN.F,"%s",tstring);
					if(f!=1) mywhine("problem reading file for sugar bins.");
					}
				}
			for (i=0;i<4;i++)
				{
//printf("Set %d \n",i);
				f=fscanf(IN.F,"%s",tstring);
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
//fflush(stdout);
		}
	fclose(IN.F);
	}

for (i=0;i<4;i++) 
	{
	for (d2=0;d2<NG;d2++)
		{
		for (d1=0;d1<NG;d1++)
			{
			testd1=10000*(double)GRID[i][d1][d2]/(double)nmax[i];
			fprintf(INT_MATRIX[i].F,"%11.0f ",ceil(testd1));
			}
		fprintf(INT_MATRIX[i].F,"\n");
		}
	for (d2=0;d2<NG;d2++)
		{
		for (d1=0;d1<NG;d1++)
			{
			fprintf(IMP_MATRIX[i].F,"%11.8f ",(double)GRID[i][d1][d2]/(double)nmax[i]);
			}
		fprintf(IMP_MATRIX[i].F,"\n");
		}
	for (d1=0;d1<NG;d1++)
		{
		d1_val=-180.0+((d1+0.5)*360.0/(double)NG);
		for (d2=0;d2<NG;d2++)
			{
			d2_val=-180.0+((d2+0.5)*360.0/NG);
			testd1=(double)GRID[i][d1][d2]/(double)n;
			testd2=(double)GRID[i][d1][d2]/(double)nmax[i];
			//if ( ( testd1 < 0.00000001 ) || ( testd2 < 0.00000001 ) )  continue;
			fprintf(CONT_XYZ[i].F,"%8.3f\t%8.3f\t%11.8f\t%11.8f\t%11.0f\n",\
				d1_val,d2_val,(double)GRID[i][d1][d2]/(double)n,(double)GRID[i][d1][d2]/(double)nmax[i],ceil(1000*testd2));
			}
		fprintf(CONT_XYZ[i].F,"\n");
		}
	}
for (i=0;i<4;i++)
	{
	fclose(INT_MATRIX[i].F);
	fclose(IMP_MATRIX[i].F);
	fclose(CONT_XYZ[i].F);
	}


return 0;
}
