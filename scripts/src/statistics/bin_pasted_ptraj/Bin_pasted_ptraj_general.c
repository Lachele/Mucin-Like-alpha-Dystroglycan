#include <glylib.h>

#define USAGE "\n\
      Usage:\n\
            bin_pasted_ptraj nGrid File1 File2 OutPrefix\n\
\n\
            NOTE:  this program does not wrap angle measurements \n\
\n\
      Where: \n\
\n\
            nGrid is required - it is the number of grid spaces.\n\
\n\
            File1 is required - it is the first ptraj-style-output file. \n\
\n\
            File2 is required - it is the second ptraj-style-output file.\n\
\n\
            OutPrefix is required - it is the desired prefix for the output files.\n\
\n\
      CALL FROM: \n\
\n\
            call me from ANALYSIS \n\
\n\
The program will: \n\
  - Read in all the the two files \n\
  - Ignore lines beginning with a hash (#) \n\
  - Output 2D bins with NGxNG divisions in multiple formats \n\
"

int main(int argc, char *argv[])
{
int i=0,t=0,f1=0,f2=0,d1=0,d2=0,n=0,nmax,**GRID; /* amino acid position iterator */
fileset IN1,IN2,CONT_XYZ; /* IMP_MATRIX is normd to max value; CONT to total n */
fileset IMP_MATRIX,INT_MATRIX;
char tstring1[100],tstring2[100],line[1000],*OUTPUT_PREFIX;
double dtemp=0,d1_val,d2_val,testd1,testd2;
int NG=-1;

if(argc<5) mywhineusage("Incorrect number of arguments.",USAGE);

sscanf(argv[1],"%d",&NG);
if(MAXRUNS<0) mywhine("Something went wrong scanning n grid.");

IN1.N=strdup(argv[2]);
IN1.N=strdup(argv[3]);
OUTPUT_PREFIX=strdup(argv[4]);

/* allocate grid space */
GRID=(int**)calloc(4, sizeof(int*));
for(f=0;f<NG;f++) GRID[i][f]=(int*)calloc(NG, sizeof(int));

/* Generate output file names and open the input files */
IMP_MATRIX.N=(char*)calloc(strlen(OUTPUT_PREFIX)+7+strlen(argv[1]), sizeof(char));
sprintf(IMP_MATRIX.N,"%s%s_IMP_%d",OUTPUT_PREFIX,argv[1],i+1);
IMP_MATRIX.F=myfopen(IMP_MATRIX.N,"w");

INT_MATRIX.N=(char*)calloc(strlen(OUTPUT_PREFIX)+7+strlen(argv[1]), sizeof(char));
sprintf(INT_MATRIX.N,"%s%s_INT_%d",OUTPUT_PREFIX,argv[1],i+1);
INT_MATRIX.F=myfopen(INT_MATRIX.N,"w");

CONT_XYZ.N=(char*)calloc(strlen(OUTPUT_PREFIX)+8+strlen(argv[1]), sizeof(char));
sprintf(CONT_XYZ.N,"%s%s_CONT_%d",OUTPUT_PREFIX,argv[1],i+1);
CONT_XYZ.F=myfopen(CONT_XYZ.N,"w");

nmax=0;
n=0;
/* Open the input files */
IN1.F=myfopen(IN1.N,"r");
IN2.F=myfopen(IN2.N,"r");
	/* see if this is the first line of the file */
tstring[0]='\0';
f1=fscanf(IN1.F,"%s",tstring1);
f2=fscanf(IN2.F,"%s",tstring2);
//printf("line is >>%s",line);
while (f1!=EOF) 
	{
	if(f2==EOF) mywhine("The two files to be pasted appear to have diffeent sizes");
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
		f1=fscanf(IN1.F,"%s",tstring);
		f2=fscanf(IN2.F,"%s",tstring);
//printf("line is >>%s",line);
//fflush(stdout);
		}
if(f2!=EOF) mywhine("The two files to be pasted appear to have diffeent sizes");
fclose(IN.F);

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
