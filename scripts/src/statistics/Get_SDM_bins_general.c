#include <glylib.h>

#define DEBUG_LEVEL 0
#define bigMaxSDMBins 100

typedef struct {
	int n; /**< Number of points included here */
	int N; /**< Number of doubles in original data set */
	double Mean; /**< the mean value for the overall set of data */
	int *I; /**< The numbers of bins for each point */
	int **BinSz; /**< The individual bin sizes corresponding to I */
	double *SDM; /**< Standard deviation of the mean for each bin set */
	int nFit; /**< The number of linear fits performed */
	int *Fit; /**< The number of points used in each fit */
	double *sdm1, *sdm2; /**< extrapolated values for the SDM per *Fit using two methods */
	double *slope1, *slope2; /**< extrapolated values for the SDM per *Fit using two methods */
} SDMInfo;

#define USAGE "\n\
	SDMInfo getSDMInfo(int N, double* DATA) \n\
\n\
where: \n\
\n\
	N is the number of doubles pointed to by DATA\n\
\n\
        The function will return an SDMInfo structure containing bin info\n\
        for 2 to 100 bins or 50% of N, whichever is less.\n\
\n\
        When N is not a multiple of a bin number, a random choice of bins \n\
        will be increased by one (consecutive) member.  The sizes of the\n\
        bins will be stored in BinSz[n][i=1 to n].\n\
\n\
        A series of straight-line fits will be made using two methods in \n\
        increments of five points up to a maximum of n.  The intercepts\n\
        will be listed in sdm1 and sdm2 (slopes in slope1 and slope2).\n\
\n\
        Please see the SDMInfo structure for more information.\n\
\n"

/***************************  main() *******************************/
SDMInfo getSDMInfo(int N, double *DATA){
int i=0,j=0,k=0,l=0;
int MAXBINS=0,BASENUM=0,EXTRAS=0,**Leftover;
double *MEANS,temp; 
meanvar MV;
statsarray SA;
SDMInfo  SDI;

/* 
	Determine the maximum number of bins to use
*/
if ( N >= 2*bigMaxSDMBins ) MAXBINS=bigMaxSDMBins;
else MAXBINS=floor(N/2);
SDI.n=MAXBINS;
SDI.N=N;
SDI.nFit=floor((SDI.n-1)/5);
/* Alocate cleared memory */
MEANS=(double*)calloc(MAXBINS,sizeof(double));
SDI.I=(int*)calloc(MAXBINS,sizeof(int));
SDI.SDM=(double*)calloc(MAXBINS,sizeof(double));
SDI.Fit=(int*)calloc(SDI.nFit,sizeof(int));
SDI.sdm1=(double*)calloc(SDI.nFit,sizeof(double));
SDI.sdm2=(double*)calloc(SDI.nFit,sizeof(double));
SDI.slope1=(double*)calloc(SDI.nFit,sizeof(double));
SDI.slope2=(double*)calloc(SDI.nFit,sizeof(double));
/*
	For each bin, determine the number of points to assign
*/
Leftover=(int**)calloc(MAXBINS,sizeof(int*));
SDI.BinSz=(int**)calloc(MAXBINS,sizeof(int*));
//printf("Maxbins=%d\n",MAXBINS);
for(i=0;i<MAXBINS;i++)
	{
	SDI.BinSz[i]=(int*)calloc(i+1,sizeof(int));
	BASENUM=floor(N/(i+1));
	EXTRAS=N%(i+1);
//printf("i=%d; BASENUM=%d; EXTRAS=%d\n",i,BASENUM, EXTRAS);
	for(j=0;j<i+1;j++) 
		{
		SDI.BinSz[i][j]=BASENUM;
		Leftover[j]=&(SDI.BinSz[i][j]);
//printf("Leftover[%d] is %d\n",j,Leftover[j][0]);
		}
	k=i+1;
	while(EXTRAS>0)
		{
		temp=rand()/(double)RAND_MAX;
		j=floor(((double)k)*temp);
//printf("k is %d; temp is %f; j is %d; EXTRAS is %d\n",k,temp,j,EXTRAS);
		if(Leftover[j][0]!=BASENUM) mywhine("pointer issue in getSDMInfo extras");
		Leftover[j][0]++;
		EXTRAS--;
		k--;
//printf("Leftover[j=%d][0]=%d; [k=%d][0]=%d\n",j,Leftover[j][0],k,Leftover[k][0]);
		if ((EXTRAS>0)&&(k>j)) Leftover[j] = &(Leftover[k][0]);
//printf("Leftover[j=%d][0]=%d; [k=%d][0]=%d\n",j,Leftover[j][0],k,Leftover[k][0]);
		}
	}

if (DEBUG_LEVEL >2) 
{
for(i=0;i<MAXBINS;i++)
 {
 printf("Showing bin sizes for set %d:",i+1);
 for(j=0;j<i+1;j++)
  {
  printf("\t%d",SDI.BinSz[i][j]);
  }
 printf("\n");
 }
}

/*
	Determine in the averages for each bin
*/
for(i=0; i<MAXBINS; i++)
  {
  k=0;
  SDI.I[i]=i+1;

if(DEBUG_LEVEL>2){printf("Showing Means for set %d:",i+1);}

  for(j=0;j<=i;j++) { 
	l=0;
	while (l<SDI.BinSz[i][j])
		{
		MEANS[j]+=DATA[k]; 
		l++;
		k++;
		}
	MEANS[j]	/=	SDI.BinSz[i][j];

if(DEBUG_LEVEL>2){printf("\t%f",MEANS[j]);}

  	}

if(DEBUG_LEVEL>2){printf("\n");}

  SA.d		=	MEANS;
  if(i==0) SA.d	=	DATA;
  SA.t		=	's';
  SA.n		=	i+1;
  if(i==0) SA.n	=	N;
  MV		=	get_meanvar_array( SA );
  SDI.SDM[i]	=	MV.s;
  if(i==0) SDI.Mean =   MV.m;

if(DEBUG_LEVEL>2){printf("SDI.SDM[%d]  =  %f\n",i,SDI.SDM[i]);}

  for(k=0;k<MAXBINS;k++) MEANS[k]=0;
  }

/*
	Get the intercept of the line using the two methods.

	Method 1:  plain sdm versus log of #bins
	Method 2:  log sdm versus log of #bins

	Intercept equation (http://mathworld.wolfram.com/LeastSquaresFitting.html)

	np = MAXBINS-1

	They use f(x) = a + b*x

	For both slope and intercept, the denominator is:
	
		Demonimator = { np * Sum [xi^2] } - { Sum [xi] }^2

	SDM estimate (intercept)	
	Numerator = { Sum[yi] * Sum[xi^2] } - { Sum[xi] * Sum[xi * yi] }

	(slope)
	Numerator = { np * Sum [ xi * yi ] } - { Sum [xi] * Sum [yi] }
*/
double SumX=0,SumXX=0,SumXY1=0,SumXY2=0,SumY1=0,SumY2=0;
double logX=0,logY=0,Denominator=0;
int    np;
j=0;
for(i=1;i<SDI.n;i++)
	{
	logX=log(i+1);
	logY=log(SDI.SDM[i]);

	SumX+=logX;
	SumXX+=(logX*logX);

	SumXY1+=(logX*SDI.SDM[i]/sqrt(i+1));
	SumY1+=SDI.SDM[i]/sqrt(i+1);
	// old, no sqrt(n)  SumXY1+=(logX*SDI.SDM[i]);
	// old, no sqrt(n)  SumY1+=SDI.SDM[i];

	SumXY2+=(logX*logY);
	SumY2+=logY;


	if((i)%5==0)
		{
		np		=	i;
		SDI.Fit[j]	=	i;
		Denominator	=	np*SumXX - SumX*SumX;
		SDI.sdm1[j]	=	( SumY1*SumXX - SumX*SumXY1 ) / ( Denominator  );
		SDI.sdm2[j]	=	exp(( SumY2*SumXX - SumX*SumXY2 ) / ( Denominator  ));
		SDI.slope1[j]	=	( np*SumXY1 - SumX*SumY1 ) / ( Denominator  );
		SDI.slope2[j]	=	( np*SumXY2 - SumX*SumY2 ) / ( Denominator  );
//printf("j=%d Fit[j]=%d sdm1[j]=%f sdm2[j]=%f slope1[j]=%f slope2[j]=%f\n",
	//j,SDI.Fit[j],SDI.sdm1[j],SDI.sdm2[j],SDI.slope1[j],SDI.slope2[j]);
		j++;
		}
	}

return SDI;
}
