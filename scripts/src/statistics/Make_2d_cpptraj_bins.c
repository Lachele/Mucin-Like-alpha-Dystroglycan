#include "glylib.h"
#define USAGE "\n\
	makeMDBins File Col1 Col2 Prefix Num_sets \n\
\n\
where: \n\
	File \n\
            The file format should be like output from cpptraj.\n\
            If the file contains blank lines, things won't work properly.\n\
\n\
	Col1 & Col2 \n\
            The 2 columns from File that you want 2D-binned.\n\
\n\
	Num_Sets is the maximum number of sub-sets for dividing the data \n\
            Num_Sets need not be a factor of the number of points.  If not,\n\
            bins at the edges might not be good population representations\n\
            currently, both dimensions get the same number of bins.\n\
\n"

/***************************  main() *******************************/
int main(int argc, char *argv[]){
int bins,**BIN,npts,i,j,k,d1,d2,nmax=0;
int Col1,Col2,linesz=0,readsz=0,nlines;
double widthtot1,binwidth1,widthtot2,binwidth2;
double *PTS1,*PTS2,maxp1=0,minp1=0,maxp2=0,minp2=0,cntr1=0,cntr2=0;
FILE *IF,*XYZ;
// *IMP,*INT;
char *temp,*OUTPREF,*temp2;
/* this is for letting the columns be in either order.  */
double *LowDat,*HiDat;
int *CLow,*CHi;

/* Check input for sanity */
if ( argc != 6 )	{
		mywhineusage("Incorrect number of arguments.", USAGE); }

/* Here, npts is just being used as a dummy variable */
npts		=	sscanf( argv[5], "%d", &bins);
if( npts != 1 )		mywhineusage ("Num_sets appears not to be an integer.", USAGE);
BIN		=	(int**) calloc ( bins, sizeof(int*) );
for(i=0;i<bins;i++) BIN[i]=(int*)calloc(bins,sizeof(int));

IF		=	myfopen( argv[1], "r" ); 
OUTPREF		=	strdup( argv[4] );
if(sscanf(argv[2],"%d",&Col1)!=1) mywhine("Problem reading Column number 1");
if(sscanf(argv[3],"%d",&Col2)!=1) mywhine("Problem reading Column number 2");

/* Figure out how much space we need */
nlines	=	cscan_file( IF, '\n' ); 
npts	=	nlines - 1;
PTS1	=	(double*) calloc (npts, sizeof(double));
PTS2	=	(double*) calloc (npts, sizeof(double));
printf("Found %d lines in the file; starting with %d points\n",nlines,npts);
rewind(IF);

/* Do file sanity checks. 
	Make sure it looks like cpptraj output
	Make sure the columns exist 
	See how long the lines are */

i=getc(IF);
if(i==EOF)	mywhine("Input file appears to be empty."); 
if(i!='#')	mywhine("This doesn't appear to be a cpptraj output file (no beginning hash mark).");
linesz=0;
while((i!='\n')&&(i!=EOF)) 
	{
	linesz++;
	i=getc(IF);
	}

readsz=linesz+100;
temp=(char*)calloc(readsz+100,sizeof(char));
temp2=(char*)calloc(readsz+100,sizeof(char));
rewind(IF);
if(fgets(temp,readsz,IF)==NULL) 	mywhine("Something went very wrong in the file read."); 
//printf("temp (tip top) is >>%s<<\n",temp);
if(strchr(temp,'\n')==NULL) 		mywhine("Something went wrong counting the line length.");
/* Set low and hi col pointers */
if(Col1<Col2)
	{
	CLow=&Col1;
	LowDat=&PTS1[0];
	CHi=&Col2;
	HiDat=&PTS2[0];
	}
else
	{
	CLow=&Col2;
	LowDat=&PTS2[0];
	CHi=&Col1;
	HiDat=&PTS1[0];
	}
START HERE
fix the string read thing...  sscanf starts over every time...  (just use fscanf?)
for(i=0;i<CLow[0];i++) if(sscanf(temp,"%s",temp2)!=1) mywhine("Can't find the low column.");
for(i=CLow[0];i<CHi[0];i++) if(sscanf(temp,"%s",temp2)!=1) mywhine("Can't find the high column.");

printf("linesz is %d\n",linesz);

i=0; /* the current line index from the file */
j=0; /* the current points index in the PTS arrays */
k=0; /* counter for scanning across the columns */
while(i<nlines-1)
  {
  if(fgets(temp,readsz,IF)==NULL) 	mywhine("Unexpected end of file.");
//printf("temp (top) is >>%s<<\n",temp);
  if(strchr(temp,'\n')==NULL) 		mywhine("A line in the file is much longer than expected.");
  if(temp[0]=='#') 
	{
	npts--;
	i++;
	continue;
	}
  for(k=0;k<CLow[0];k++) if(sscanf(temp,"%s",temp2)!=1) mywhine("Can't find the low column (in the array read).");
  if(sscanf(temp2,"%lf",&LowDat[j])!=1) { mywhine("problem reading data for the low column"); }
printf("temp2 (CLow) is >>%s<<\n",temp2);
  for(k=CLow[0];k<CHi[0];k++) if(sscanf(temp,"%s",temp2)!=1) mywhine("Can't find the high column (in the array read).");
  if(sscanf(temp2,"%lf",&HiDat[j])!=1) { mywhine("problem reading data for the high column"); }
printf("temp2 (CHi) is >>%s<<\n",temp2);

printf("i is %d ; j is %d ; LowDat is %f ; HiDat is %f \n",i,j,LowDat[j],HiDat[j]);
  if(j==0) 
	{
	maxp1=minp1=LowDat[0];
	maxp2=minp2=HiDat[0];
	}
  else
	{
	if(minp1>LowDat[j])	minp1=LowDat[j];
	if(maxp1<LowDat[j])	maxp1=LowDat[j];
	if(minp2>HiDat[j])	minp2=HiDat[j];
	if(maxp2<HiDat[j])	maxp2=HiDat[j];
	}
	i++;
	j++;
  }

printf("npts is %d ; minp/maxp 1 = %f %f ; for 2:  %f %f\n",npts,minp1,maxp1,minp2,maxp2);

widthtot1	=	(double)(maxp1-minp1);
binwidth1	=	widthtot1/(double)bins;
widthtot2	=	(double)(maxp2-minp2);
binwidth2	=	widthtot2/(double)bins;
printf("width and binwid 1 and 2 are: w1 %f b1 %f w2 %f b2 %f\n",widthtot1,binwidth1,widthtot2,binwidth2);

//printf("1\n");
for(i=0;i<npts;i++) 
	{ 
	if(PTS1[i]==maxp1) d1=bins-1;
	else d1=(floor)( (PTS1[i]-minp1) / binwidth1 );
	if(PTS2[i]==maxp2) d2=bins-1;
	else d2=(floor)( (PTS2[i]-minp2) / binwidth2 );
	BIN[d1][d2]++; 
	if ( BIN[d1][d2] > nmax ) nmax = BIN[d1][d2];
	}

//printf("2\n");
sprintf(temp,"%s_XYZ_bins.txt",OUTPREF);  
XYZ		=	myfopen(temp,"w");
//sprintf(temp,"%s_Matrix_bins.txt",OUTPREF);
//IMP		=	myfopen(temp,"w");
//sprintf(temp,"%s_iMatrix_bins.txt",OUTPREF);
//INT		=	myfopen(temp,"w");

fprintf(XYZ,"#Bin1\tBin2\tover npts\tover nmax\tCounts\tmax1000\n");
for(i=0;i<bins;i++) 
  {
  for(j=0;j<bins;j++) 
    {
    cntr1	=	(minp1+0.5*(2*i+1)*binwidth1);
    cntr2	=	(minp2+0.5*(2*j+1)*binwidth2);
    fprintf(XYZ,"%g\t%g\t%10.5f\t%10.5f\t%d\t%10.0f\n",cntr1,cntr2,(double)BIN[i][j]/npts,(double)BIN[i][j]/nmax,BIN[i][j],1000*(double)BIN[i][j]/nmax);
    }
    fprintf(XYZ,"\n");
  }

return 0;
}
