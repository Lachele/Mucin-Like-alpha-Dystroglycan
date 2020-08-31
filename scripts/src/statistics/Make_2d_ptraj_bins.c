#include "glylib.h"
#define USAGE "\n\
	make2DBins File1 File2 Prefix Num_sets \n\
\n\
where: \n\
	File1 and File2 \n\
            The file format should be like output from ptraj.\n\
            Both files should be the same size.\n\
\n\
	Num_Sets is the maximum number of sub-sets for dividing the data \n\
            Num_Sets need not be a factor of the number of points.  If not,\n\
            bins at the edges might not be good population representations\n\
            currently, both dimensions get the same number of bins.\n\
\n"

/***************************  main() *******************************/
int main(int argc, char *argv[]){
int bins,**BIN,npts,i,j,d1,d2,nmax=0;
double widthtot1,binwidth1,widthtot2,binwidth2,SqrtN;
double *PTS1,*PTS2,maxp1=0,minp1=0,maxp2=0,minp2=0,cntr1=0,cntr2=0;
FILE *IF1,*IF2,*XYZ;
// *IMP,*INT;
char temp[250],*OUTPREF;

/* Check input for sanity */
if ( argc != 5 )	{
		mywhineusage("Incorrect number of arguments.", USAGE); }

/* Here, npts is just being used as a dummy variable */
npts		=	sscanf( argv[4], "%d", &bins);
if( npts != 1 )		mywhineusage ("Num_sets appears not to be an integer.", USAGE);
BIN		=	(int**) calloc ( bins, sizeof(int*) );
for(i=0;i<bins;i++) BIN[i]=(int*)calloc(bins,sizeof(int));

IF1		=	myfopen( argv[1], "r" ); 
IF2		=	myfopen( argv[2], "r" ); 
OUTPREF		=	strdup( argv[3] );

/* Figure out how much space we need */
npts	=	cscan_file( IF1, '\n' );
i	=	cscan_file( IF2, '\n' );
if(i!=npts) mywhine("The two files must be the same size!");
PTS1	=	(double*) calloc (npts, sizeof(double));
PTS2	=	(double*) calloc (npts, sizeof(double));
printf("Found %d data points in each file\n",npts);
rewind(IF1);
rewind(IF2);

i=0;
while(i<npts)
  {
  if(fscanf(IF1,"%s",temp)==EOF) 	break; 
  if(fscanf(IF2,"%s",temp)==EOF) 	break; 
//printf("temp (top) is >>%s<<\n",temp);
  if(fscanf(IF1,"%lf",&PTS1[i])!=1) { mywhine("problem reading File 1"); }
  if(fscanf(IF2,"%lf",&PTS2[i])!=1) { mywhine("problem reading File 2"); }
  if(i==0) 
	{
	maxp1=minp1=PTS1[0];
	maxp2=minp2=PTS2[0];
	}
  else
	{
	if(minp1>PTS1[i])	minp1=PTS1[i];
	if(maxp1<PTS1[i])	maxp1=PTS1[i];
	if(minp2>PTS2[i])	minp2=PTS2[i];
	if(maxp2<PTS2[i])	maxp2=PTS2[i];
	}
	i++;
  }

printf("minp/maxp 1 = %f %f ; for 2:  %f %f\n",minp1,maxp1,minp2,maxp2);

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

fprintf(XYZ,"#Bin1\tBin2\tover npts\tover nmax\tCounts\tmax1000\tover sqrtnpts\n");
for(i=0;i<bins;i++) 
  {
  for(j=0;j<bins;j++) 
    {
    cntr1	=	(minp1+0.5*(2*i+1)*binwidth1);
    cntr2	=	(minp2+0.5*(2*j+1)*binwidth2);
    SqrtN	= 	sqrt((double)npts);
    if(BIN[i][j]>SqrtN) printf("count (%d) in BIN[%d][%d] is larger than SqrtN (%.2f)\n",BIN[i][j],i,j,SqrtN);
    fprintf(XYZ,"%g\t%g\t%10.5f\t%10.5f\t%d\t%10.0f\t%10.5f\n",cntr1,cntr2,(double)BIN[i][j]/npts,(double)BIN[i][j]/nmax,BIN[i][j],1000*(double)BIN[i][j]/nmax,(double)BIN[i][j]/SqrtN);
    }
    fprintf(XYZ,"\n");
  }

return 0;
}
