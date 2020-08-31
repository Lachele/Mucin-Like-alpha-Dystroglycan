/** file do_GalNAc_analysis.c

Purpose:  This program does some extra HBond analysis for the d4g runset.

More info:  

	This program requires the following:

		* That it be run from the d4g/ANALYSIS/GalNAc directory

	This program will automatically do the following:

		* Find and read in the parm7 and mdcrd files for a given runset.

	It concerns itself only with the N-H of the GalNAc's NAc part and the 
		O=C's in the nearest backbone locations. 

	It will write one file for each of the four GalNAc's, each containing 
		the following information:

		1.  GalNAc-N --- O-nearest-backbone distance
		2.  GalNAc-N-H --- O-nearest-backbone angle
		3.  GalNAc-N --- O-glycosidic distance
		4.  GalNAc-N-H --- O-glycosidic angle
		5.  Sum of [1] and [3], above
		6.  O-backbone -- H(NAc) distance
		7.  O-glycosidic -- H(NAc) distance
		8.  Sum of [6] and [7] 
		9.  O-backbone -- H(NAc) -- O-glycosidic angle
		10. H(NAc) -- O-glycosidic -- O-backbone angle
		11. O-glycosidic -- N-NAc -- O-backbone angle

		These four files can be concatenated separately if desired.

	It will also produce several bin files.  Each bin file will contain info for 
		each of the four GalNAc's individually as well as collectively.

		All binned data will be normalized.  The counts can be recovered by
			multiplying fractions by the total counts (column headers).
		
		The desired bin info is items 1-9 above, plus:

		A:  2-D bins GalNAc-N --- O-nearest-backbone vs N-H -- O angle
		B:  2-D bins GalNAc-N --- O-glycosidic vs N-H -- O angle
		C:  2-D bins for [6] vs [9]
		D:  2-D bins for [7] vs [9]
		E:  2-D bins for [8] vs [9]
		F:  2-D bins for [6] vs [10]
		G:  2-D bins for [5] vs [11]

	For the binning, I'll consider all angles and distances from 2 to 7.  See
		defined bin settings below for details.

	It will also write to trajectory files, the frames that match the 
		following criteria.  It will also print to the log file the runsets
		and frame numbers from which they come with the values below.

			GalNAc# 	N - H - Ob	N -- Ob		Og - H - Ob	H -- Ob

		Z: 	3 		120-140		3-3.25		*
		Y:	3		70-80		4.8-5		*
		X:	3		100-120		6.5-6.75	*
		W:	4		80-100		3.3-3.8		*
		V:	3		0-180		0.0-4.5		*

	NEED TO ADD:

	Trajectory files for each GalNAc according to the following criteria:

		N--Ob < 4.5  and  N-H-Ob > 110
		N--Ob < 4.5  and  N-H-Ob < 110
		4.5 < N--Ob < 6
		N--Ob > 6

	Also summary counts for each section and summary counts for all runs together.
*/

#include <glylib.h>

#define DEBUGLEVEL 0

#define USAGE "\n\
        GalNAc_analysis PREFIX number_sims \n\
                Where:\n\
                    Prefix is a prefix for output files\n\
                    number_sims is the number of simulations for this runset\n\
"

#define ABINNUM 180 	/**< Number of bins in angle */
#define ABINMIN 0.0 	/**< Minimum angle bin */
#define ABINMAX 180.0 	/**< Maximum angle bin */
#define ABINSZ  (ABINMAX-ABINMIN)/(double)ABINNUM
#define LBINNUM 220 	/**< Number of bins in length */
#define LBINMIN 1.0 	/**< Minimum length bin */
#define LBINMAX 12.0 	/**< Maximum length bin */
#define LBINSZ  (LBINMAX-LBINMIN)/(double)LBINNUM
#define RtoD  180.0/PI 	/**< multiply by this to get degrees */
#define nB1D    11      /**< how many 1D bin files to make */
#define nB2D     7      /**< how many 2D bin files to make */

#define OFSUFFIX ".txt"

#define NTRAJ	5 /**< Number of trajectory files to write out */
typedef struct {
	int n; /**< the GalNAc number (1-4) to which this applies */
	fileset F; /**< fileset info for saving the coords */
	double Alo; /**< low end of the angle range */
	double Ahi; /**< high end of the angle range */
	double Dlo; /**< low end of the distance range */
	double Dhi; /**< high end of the distance range */
/* 	GalNAc# 	N - H - Ob	N -- Ob		Og - H - Ob	H -- Ob

Z: 	3 		120-140		3-3.25		*
Y:	3		70-80		4.8-5		*
X:	3		100-120		6.5-6.75	*
W:	4		80-100		3.3-3.8		* 
V:	3		0-180		0.0-4.5		* */
} crdsaveinfo; 

typedef struct {
	int *NOb; /**< [200], Length from NAc N to backbone O */
	int *NOg; /**< [200], Length from NAc N to glycosidic O */
	int *NHOb; /**< [180], Angle from NAc N to H to backbone O */
	int *NHOg; /**< [180], Angle from NAc N to H to glycosidic O */
	int *NOSUM; /**< [200], Sum of NObak and NOgly */
	int *HOb;  /**< [200], Length from NAc H to backbone O */
	int *HOg;  /**< [200], Length from NAc H to glycosidic O */
	int *HOSUM;  /**< [200], Length from NAc H to glycosidic O */
	int *ObHOg; /**< [180], Angle from back O to NAc H to glyco O */
	int *HOgOb; /**< [180], Angle from back O to glyco O to NAc H*/
	int *ONO; /**< [180], Angle from back O to NAc N to glyco O */
	int **Bak2D; /**< [200][180], 2D bins of NObak vs NHObak */
	int **Gly2D; /**< [200][180], 2D bins of NOgly vs NHOgly */
	int **HOb2OHO; /**< [200][180], 2D bins of Bak HO to OHO */
	int **HOg2OHO; /**< [200][180], 2D bins of Gly HO to OHO */
	int **SUM2OHO; /**< [200][180], 2D bins of Bak+Gly HO to OHO */
	int **HOb2OOH; /**< [200][180], 2D bins of Bak HO to O-bak -- O-gly -- H */
	int **NOSumONO; /**< [200][180], 2D bins of Bak+Gly HO to OHO */
} binset;

int main (int argc, char *argv[])
{
int ai, /**< atom index */
    ri, /**< residue index */
    tsi, /**< trajectory set index */
    i,j,k,l, /**< generic counters */
    xfi, /**< for line termination in coordinate writes */
    angi, /**< angle index into bins */
    leni, /**< length index into bins */
    ttot,  /**< total number of trajectory frames */
    nsim, /**< number of simulations */
    nBtots=11,Btots[11], /**< how many and space for reusable integers  */
    prefl; /**< strlen for the PREFIX */
int 	test, /**< for file status */
	ltmp=0; /**< for calculating string lengths */
crdsaveinfo *CRD; /**< for saving frames from the trajectory */
assembly A;
fileset PF,/**< prmtop file */
	ICF, /**< trajcrd file in */
	DAT[4], /**< array of raw data files (one per GalNAc) */
	B1D[nB1D], /**< array of 1-D binned files */
	B2D[nB2D], /**< array of 2-D binned files */
	LOG; /**< log file */
char 	*PREF; /**< Prefix for output files */
double	angle, /**< reusable angle calc */
	nosum=0, /**< for convenience with NO sum vs ONO */
	length1, /**< reusable N-Obak calc */
	length2; /**< reusable N-Oglyc calc */
molindex NAcN[4], /**< The four GalNAc NAc N's */
	NAcH[4], /**< The four GalNAc NAc H's */
	OLTO[4], /**< The four OLT backbone O's */
	GLYO[4]; /**< The four glycosidic O's */
coord_3D  c1, c2, c3;
binset B[4];

if(argc!=3) myusage(USAGE);

/** Do some initializations and such */
prefl=strlen(argv[1]);
PREF=&(argv[1][0]);
if(sscanf(argv[2],"%d",&nsim)!=1) mywhine("coudn't get the number of simulations");
/*	GalNAc# 	N - H - Ob	N -- Ob		Og - H - Ob	H -- Ob

Z: 	3 		120-140		3-3.25		*
Y:	3		70-80		4.8-5		*
X:	3		100-120		6.5-6.75	*
W:	4		80-100		3.3-3.8		*  
V:	3		0-180		0.0-4.5		*                        */
CRD=(crdsaveinfo*)calloc(NTRAJ,sizeof(crdsaveinfo));
CRD[0].n=CRD[1].n=CRD[2].n=CRD[4].n=3;
CRD[3].n=4;
CRD[0].F.N=strdup("GalNAC_3_region1_NHOb-vs-NOb.trajcrd");
CRD[1].F.N=strdup("GalNAC_3_region2_NHOb-vs-NOb.trajcrd");
CRD[2].F.N=strdup("GalNAC_3_region3_NHOb-vs-NOb.trajcrd");
CRD[3].F.N=strdup("GalNAC_4_region1_NHOb-vs-NOb.trajcrd");
CRD[4].F.N=strdup("GalNAC_3_region4_NHOb-vs-NOb.trajcrd");
CRD[0].F.F=myfopen(CRD[0].F.N,"w");
CRD[1].F.F=myfopen(CRD[1].F.N,"w");
CRD[2].F.F=myfopen(CRD[2].F.N,"w");
CRD[3].F.F=myfopen(CRD[3].F.N,"w");
CRD[4].F.F=myfopen(CRD[4].F.N,"w");
fprintf(CRD[0].F.F,"Trajectory portions written for set Z (see source code) by GalNAc_analysis\n");
fprintf(CRD[1].F.F,"Trajectory portions written for set Y (see source code) by GalNAc_analysis\n");
fprintf(CRD[2].F.F,"Trajectory portions written for set X (see source code) by GalNAc_analysis\n");
fprintf(CRD[3].F.F,"Trajectory portions written for set W (see source code) by GalNAc_analysis\n");
fprintf(CRD[4].F.F,"Trajectory portions written for set V (see source code) by GalNAc_analysis\n");
CRD[0].Alo=120.0;
CRD[0].Ahi=140.0;
CRD[0].Dlo=3.0;
CRD[0].Dhi=3.25;
CRD[1].Alo=70.0;
CRD[1].Ahi=80.0;
CRD[1].Dlo=4.8;
CRD[1].Dhi=5.0;
CRD[2].Alo=100.0;
CRD[2].Ahi=120.0;
CRD[2].Dlo=6.5;
CRD[2].Dhi=6.75;
CRD[3].Alo=80.0;
CRD[3].Ahi=100.0;
CRD[3].Dlo=3.3;
CRD[3].Dhi=3.8;
CRD[4].Alo=0.0;
CRD[4].Ahi=180.0;
CRD[4].Dlo=0.0;
CRD[4].Dhi=4.5;

for(i=0;i<4;i++)
	{
	B[i].NOb=(int*)calloc(LBINNUM,sizeof(int)); /**< [200], Length from NAc N to backbone O */
	B[i].NOg=(int*)calloc(LBINNUM,sizeof(int)); /**< [200], Length from NAc N to glycosidic O */
	B[i].HOb=(int*)calloc(LBINNUM,sizeof(int)); /**< [200], Length from NAc H to backbone O */
	B[i].HOg=(int*)calloc(LBINNUM,sizeof(int)); /**< [200], Length from NAc H to glycosidic O */
	B[i].NHOb=(int*)calloc(ABINNUM,sizeof(int)); /**< [180], Angle from NAc N to H to backbone O */
	B[i].NHOg=(int*)calloc(ABINNUM,sizeof(int)); /**< [180], Angle from NAc N to H to glycosidic O */
	B[i].ObHOg=(int*)calloc(ABINNUM,sizeof(int)); /**< [180], Angle from back O to NAc H to glyco O */
	B[i].HOgOb=(int*)calloc(ABINNUM,sizeof(int)); /**< [180], Angle from back O to glyco O to NAc H */
	B[i].ONO=(int*)calloc(ABINNUM,sizeof(int)); /**< [180], Angle from back O to NAc N to glyco O */
	B[i].NOSUM=(int*)calloc(LBINNUM,sizeof(int)); /**< [200], Sum of NObak and NOgly */
	B[i].HOSUM=(int*)calloc(LBINNUM,sizeof(int)); /**< [200], Sum of HObak and HOgly */
	B[i].Bak2D=(int**)calloc(LBINNUM,sizeof(int*)); /**< [200][180], 2D bins of NObak vs NHObak */
	B[i].Gly2D=(int**)calloc(LBINNUM,sizeof(int*)); /**< [200][180], 2D bins of NOgly vs NHOgly */
	B[i].HOb2OHO=(int**)calloc(LBINNUM,sizeof(int*)); /**< [200][180], 2D bins of Bak HO to OHO */
	B[i].HOg2OHO=(int**)calloc(LBINNUM,sizeof(int*)); /**< [200][180], 2D bins of Gly HO to OHO */
	B[i].SUM2OHO=(int**)calloc(LBINNUM,sizeof(int*)); /**< [200][180], 2D bins of Bak+Gly HO to OHO */
	B[i].HOb2OOH=(int**)calloc(LBINNUM,sizeof(int*)); /**< [200][180], 2D bins of Bak HO to OOH */
	B[i].NOSumONO=(int**)calloc(LBINNUM,sizeof(int*)); /**< [200][180], 2D bins of Bak+Gly NO to ONO */
	for(j=0;j<LBINNUM;j++)
		{
		B[i].Bak2D[j]=(int*)calloc(ABINNUM,sizeof(int)); 
		B[i].Gly2D[j]=(int*)calloc(ABINNUM,sizeof(int)); 
		B[i].HOb2OHO[j]=(int*)calloc(ABINNUM,sizeof(int)); 
		B[i].HOg2OHO[j]=(int*)calloc(ABINNUM,sizeof(int)); 
		B[i].SUM2OHO[j]=(int*)calloc(ABINNUM,sizeof(int)); 
		B[i].HOb2OOH[j]=(int*)calloc(ABINNUM,sizeof(int)); 
		B[i].NOSumONO[j]=(int*)calloc(ABINNUM,sizeof(int)); 
		}
	}
/** Open the log file and write initial information */
LOG.N=(char*)calloc(prefl+strlen("_logfile.txt")+1,sizeof(char));
sprintf(LOG.N,"%s_logfile.txt",argv[1]);
LOG.F=myfopen(LOG.N,"w");
fprintf(LOG.F,"# Starting GalNAc H-Bond analysis for these values:\n");
fprintf(LOG.F,"#\tPREFIX = \"%s\"\n",argv[1]);
fprintf(LOG.F,"#\tnumber_sims = %s \n",argv[2]);
fprintf(LOG.F,"#\tlogfile = \"%s\" (this file)\n#\n",LOG.N);
/** Load the topology file */
PF.N=strdup("../../input/Single.parm7");
A=load_amber_prmtop(PF); 
if(A.nm!=1) mywhine("problem with topology file read");
/** Find molindexes for the important atoms 
	They are:  
		res nums	name
		4,5,6,7		O, OG1
		12,13,14,15	N2, H2N
		4,8		N
*/
for(ri=0;ri<A.m[0][0].nr;ri++)
	{
	if((A.m[0][0].r[ri].n<=7)&&(A.m[0][0].r[ri].n>=4))
		{
		i=A.m[0][0].r[ri].n-4;
		for(ai=0;ai<A.m[0][0].r[ri].na;ai++)
			{
			if(strcmp(A.m[0][0].r[ri].a[ai].N,"O")==0) OLTO[i]=A.m[0][0].r[ri].a[ai].moli;
			if(strcmp(A.m[0][0].r[ri].a[ai].N,"OG1")==0) GLYO[i]=A.m[0][0].r[ri].a[ai].moli;
			}
		}
	if((A.m[0][0].r[ri].n<=15)&&(A.m[0][0].r[ri].n>=12))
		{
		i=A.m[0][0].r[ri].n-12;
		for(ai=0;ai<A.m[0][0].r[ri].na;ai++)
			{
			if(strcmp(A.m[0][0].r[ri].a[ai].N,"N2")==0) NAcN[i]=A.m[0][0].r[ri].a[ai].moli;
			if(strcmp(A.m[0][0].r[ri].a[ai].N,"H2N")==0) NAcH[i]=A.m[0][0].r[ri].a[ai].moli;
			}
		}
	}
if(DEBUGLEVEL>0)
{
printf("The moli's are/represent:\n");
for(i=0;i<4;i++)
{
printf("%d:\n",i+1);
printf("\tOLTO: r=%d a=%d resname=%s name=%s\n",OLTO[i].r,OLTO[i].a,A.m[0][0].r[OLTO[i].r].N,A.m[0][0].r[OLTO[i].r].a[OLTO[i].a].N);
printf("\tGLYO: r=%d a=%d resname=%s name=%s\n",GLYO[i].r,GLYO[i].a,A.m[0][0].r[GLYO[i].r].N,A.m[0][0].r[GLYO[i].r].a[GLYO[i].a].N);
printf("\tNAcN: r=%d a=%d resname=%s name=%s\n",NAcN[i].r,NAcN[i].a,A.m[0][0].r[NAcN[i].r].N,A.m[0][0].r[NAcN[i].r].a[NAcN[i].a].N);
printf("\tNAcH: r=%d a=%d resname=%s name=%s\n",NAcH[i].r,NAcH[i].a,A.m[0][0].r[NAcH[i].r].N,A.m[0][0].r[NAcH[i].r].a[NAcH[i].a].N);
}
}

/** Open the output files */
ltmp=prefl+strlen("_GalNAc_12.txt")+1;
j=12;
for(i=0;i<4;i++)
	{ /**< array of raw data files (one per GalNAc) */
	DAT[i].N=(char *)calloc(ltmp,sizeof(char));
	sprintf(DAT[i].N,"%s_GalNAc_%d.txt",PREF,j);
	DAT[i].F=myfopen(DAT[i].N,"w");
	fprintf(DAT[i].F,"#%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n",\
		"Back-Len","Back-Ang","Glyc-Len","Glyc-Ang","Len-Sum","HO-Bak","HO-Gly","HO-SUM","OHO_Ang","OOH_Ang","ONO_Ang");
	j++;
	}
/* 1D #1 */
ltmp=prefl+strlen("_1D_N-O_bak.txt")+1;
B1D[0].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[0].N,"%s_1D_N-O_bak.txt",PREF);
B1D[0].F=myfopen(B1D[0].N,"w");
/* 1D #2 */
ltmp=prefl+strlen("_1D_N-H-O_bak.txt")+1;
B1D[1].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[1].N,"%s_1D_N-H-O_bak.txt",PREF);
B1D[1].F=myfopen(B1D[1].N,"w");
/* 1D #2 */
ltmp=prefl+strlen("_1D_N-O_gly.txt")+1;
B1D[2].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[2].N,"%s_1D_N-O_gly.txt",PREF);
B1D[2].F=myfopen(B1D[2].N,"w");
/* 1D #4 */
ltmp=prefl+strlen("_1D_N-H-O_gly.txt")+1;
B1D[3].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[3].N,"%s_1D_N-H-O_gly.txt",PREF);
B1D[3].F=myfopen(B1D[3].N,"w");
/* 1D #5 */
ltmp=prefl+strlen("_1D_N-O_SUM.txt")+1;
B1D[4].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[4].N,"%s_1D_N-O_SUM.txt",PREF);
B1D[4].F=myfopen(B1D[4].N,"w");
/* 1D #6 */
ltmp=prefl+strlen("_1D_H-O_bak.txt")+1;
B1D[5].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[5].N,"%s_1D_H-O_bak.txt",PREF);
B1D[5].F=myfopen(B1D[5].N,"w");
/* 1D #7 */
ltmp=prefl+strlen("_1D_H-O_gly.txt")+1;
B1D[6].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[6].N,"%s_1D_H-O_gly.txt",PREF);
B1D[6].F=myfopen(B1D[6].N,"w");
/* 1D #8 */
ltmp=prefl+strlen("_1D_H-O_SUM.txt")+1;
B1D[7].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[7].N,"%s_1D_H-O_SUM.txt",PREF);
B1D[7].F=myfopen(B1D[7].N,"w");
/* 1D #9 */
ltmp=prefl+strlen("_1D_O-H-O.txt")+1;
B1D[8].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[8].N,"%s_1D_O-H-O.txt",PREF);
B1D[8].F=myfopen(B1D[8].N,"w");
/* 1D #10 */
ltmp=prefl+strlen("_1D_O-O-H.txt")+1;
B1D[9].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[9].N,"%s_1D_O-O-H.txt",PREF);
B1D[9].F=myfopen(B1D[9].N,"w");
/* 1D #11 */
ltmp=prefl+strlen("_1D_O-N-O.txt")+1;
B1D[10].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B1D[10].N,"%s_1D_O-N-O.txt",PREF);
B1D[10].F=myfopen(B1D[10].N,"w");

/* 2D #A */
ltmp=prefl+strlen("_2D_bak.txt")+1;
B2D[0].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B2D[0].N,"%s_2D_bak.txt",PREF);
B2D[0].F=myfopen(B2D[0].N,"w");
/* 2D #B */
ltmp=prefl+strlen("_2D_gly.txt")+1;
B2D[1].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B2D[1].N,"%s_2D_gly.txt",PREF);
B2D[1].F=myfopen(B2D[1].N,"w");
/* 2D #C */
ltmp=prefl+strlen("_2D_HObak-OHO.txt")+1;
B2D[2].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B2D[2].N,"%s_2D_HObak-OHO.txt",PREF);
B2D[2].F=myfopen(B2D[2].N,"w");
/* 2D #D */
ltmp=prefl+strlen("_2D_HOgly-OHO.txt")+1;
B2D[3].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B2D[3].N,"%s_2D_HOgly-OHO.txt",PREF);
B2D[3].F=myfopen(B2D[3].N,"w");
/* 2D #E */
ltmp=prefl+strlen("_2D_HOSUM-OHO.txt")+1;
B2D[4].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B2D[4].N,"%s_2D_HOSUM-OHO.txt",PREF);
B2D[4].F=myfopen(B2D[4].N,"w");
/* 2D #F */
ltmp=prefl+strlen("_2D_HObak-OOH.txt")+1;
B2D[5].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B2D[5].N,"%s_2D_HObak-OOH.txt",PREF);
B2D[5].F=myfopen(B2D[5].N,"w");
/* 2D #G */
ltmp=prefl+strlen("_2D_NOSum-ONO.txt")+1;
B2D[6].N=(char *)calloc(ltmp,sizeof(char));
sprintf(B2D[6].N,"%s_2D_NOSum-ONO.txt",PREF);
B2D[6].F=myfopen(B2D[6].N,"w");


ttot=0;
ICF.N=(char*)calloc(strlen("../../xx/prod_all_fixed.crd")+1,sizeof(char));
/* for each simulation */
for(i=1;i<=nsim;i++) /* note!!  not starting at zero!! */
	{
	/** Open the input trajcrd file */
	sprintf(ICF.N,"../../%d/prod_all_fixed.crd",i); /**< open the new trajectory file */
	ICF.F=myfopen(ICF.N,"r");
	fprintf(LOG.F,"Opening simulation number %d\n",i);
	tsi=0;
	test=fgetc(ICF.F);
	while(test != EOF){
		ungetc(test,ICF.F);
		tsi++;
		/** Load the first/next frame in the coordinate file */
		add_trajcrds_to_prmtop_assembly(ICF,&A,'c',0);
		ttot++;
		/** For each GalNAc */
		for(j=0;j<4;j++)
			{ 
			c1=A.m[0][0].r[NAcN[j].r].a[NAcN[j].a].xa[0];
			c2=A.m[0][0].r[NAcH[j].r].a[NAcH[j].a].xa[0];
			/** Calculate N -- O-back distance 
			    Calculate N -- H -- O-back angle
			    Print these to the file */
			c3=A.m[0][0].r[OLTO[j].r].a[OLTO[j].a].xa[0];
			angle=RtoD*get_angle_ABC_points(c1,c2,c3);
			length1=get_magnitude(coord_to_vec(subtract_coord(c1,c3)));
			fprintf(DAT[j].F," %10f\t%10f\t",length1,angle);
			/** Is this a desired set?  Write out this coordinate set */
			for(l=0;l<NTRAJ;l++){
				if(CRD[l].n!=(j+1)) continue;
				if(angle<CRD[l].Alo) continue;
				if(angle>CRD[l].Ahi) continue;
				if(length1<CRD[l].Dlo) continue;
				if(length1>CRD[l].Dhi) continue;
				xfi=0;
				for(ai=0;ai<A.na;ai++)
					{
					fprintf(CRD[l].F.F,"%8.3f",A.a[ai][0].xa[0].i);
					xfi++;
					if((xfi%10)==0) fprintf(CRD[l].F.F,"\n");
					fprintf(CRD[l].F.F,"%8.3f",A.a[ai][0].xa[0].j);
					xfi++;
					if((xfi%10)==0) fprintf(CRD[l].F.F,"\n");
					fprintf(CRD[l].F.F,"%8.3f",A.a[ai][0].xa[0].k);
					xfi++;
					if((xfi%10)==0) fprintf(CRD[l].F.F,"\n");
					}
				if((xfi%10)!=0) fprintf(CRD[l].F.F,"\n");
				/* record info to log file */
				fprintf(LOG.F,"Set %d for GalNAc %d Sim %d saved frame %d\n",l+1,j+1,i,tsi+1);
				}
			/** increment the proper binset(s) */
if(DEBUGLEVEL>2) printf("Bak: LBINSZ is %f ABINSZ is %f length1 is %f angle is %f\n",LBINSZ,ABINSZ,length1,angle);
			if(angle>180) mywhine("Bad angle");
			angi = floor(angle/(ABINSZ));
			if((length1<LBINMIN)||(length1>LBINMAX)) mywhine("Length out of range");
			leni = floor((length1-LBINMIN)/(LBINSZ));
if(DEBUGLEVEL>2) printf("\t leni is %d angi is %d\n",leni,angi);
			B[j].NOb[leni]++;
			B[j].NHOb[angi]++;
			B[j].Bak2D[leni][angi]++;
			/** Calculate N -- O-glyc distance 
			    Calculate N -- H -- O-glyc angle 
			    Print these to the file */
			c3=A.m[0][0].r[GLYO[j].r].a[GLYO[j].a].xa[0];
			angle=RtoD*get_angle_ABC_points(c1,c2,c3);
			length2=get_magnitude(coord_to_vec(subtract_coord(c1,c3)));
			fprintf(DAT[j].F," %10f\t%10f\t",length2,angle);
			/** increment the proper binset(s) */
if(DEBUGLEVEL>2) printf("GLY: LBINSZ is %f ABINSZ is %f length2 is %f angle is %f\n",LBINSZ,ABINSZ,length2,angle);
			if(angle>180) mywhine("Bad angle");
			angi = floor(angle/(ABINSZ));
			if((length2<LBINMIN)||(length2>LBINMAX)) mywhine("Length out of range");
			leni = floor((length2-LBINMIN)/(LBINSZ));
if(DEBUGLEVEL>2) printf("\t leni is %d angi is %d\n",leni,angi);
			B[j].NOg[leni]++;
			B[j].NHOg[angi]++;
			B[j].Gly2D[leni][angi]++;
			/** Calculate N -- O sum 
			    Print to file and bin */
			nosum=length2+length1; /* Save nosum for use below */
if(DEBUGLEVEL>2) printf("Sum: LBINMIN is %f LBINSZ is %f length2 is %f angle is %f\n",LBINMIN,LBINSZ,length2,angle);
			if((nosum<LBINMIN)||(nosum>(LBINMAX))) mywhine("Length out of range");
			fprintf(DAT[j].F," %10f\t",nosum);
			leni = floor((nosum-LBINMIN)/(LBINSZ));
if(DEBUGLEVEL>2) printf("\t leni is %d \n",leni);
			B[j].NOSUM[leni]++;
			/* now, do it all for the O-H-O info... */
			c1=A.m[0][0].r[OLTO[j].r].a[OLTO[j].a].xa[0];
			c2=A.m[0][0].r[NAcH[j].r].a[NAcH[j].a].xa[0];
			c3=A.m[0][0].r[GLYO[j].r].a[GLYO[j].a].xa[0];
			/** Calculate H -- O-back distance 
			    Calculate H -- O-gly distance 
			    Calculate Sum of HO-gly+HO-bak distance 
			    Calculate O-gly -- H -- O-back angle
			    Print these to the file */
			length1=get_magnitude(coord_to_vec(subtract_coord(c1,c2)));
			length2=get_magnitude(coord_to_vec(subtract_coord(c2,c3)));
			angle=RtoD*get_angle_ABC_points(c1,c2,c3);
			fprintf(DAT[j].F,"%10f\t%10f\t%10f\t%10f\t",length1,length2,length1+length2,angle);
if(DEBUGLEVEL>2) printf("length1 is %f length 2 is %f the sum is %f angle is %f \n",length1,length2,length1+length2,angle);
			/** increment the proper binset(s) */
			if(angle>180) mywhine("Bad angle");
			angi = floor(angle/(ABINSZ));
			B[j].ObHOg[angi]++;
			if((length1<LBINMIN)||(length1>LBINMAX)) mywhine("Length out of range - HOb");
			leni = floor((length1-LBINMIN)/(LBINSZ));
			B[j].HOb[leni]++;
			B[j].HOb2OHO[leni][angi]++;
			if((length2<LBINMIN)||(length2>LBINMAX)) mywhine("Length out of range - HOg");
			leni = floor((length2-LBINMIN)/(LBINSZ));
			B[j].HOg[leni]++;
			B[j].HOg2OHO[leni][angi]++;
			length2+=length1;
			if((length2<LBINMIN)||(length2>(LBINMAX))) mywhine("Length out of range");
			leni = floor((length2-LBINMIN)/(LBINSZ));
			B[j].HOSUM[leni]++;
			B[j].SUM2OHO[leni][angi]++;
			/* now get the Ob-Og-H angle info */
			angle=RtoD*get_angle_ABC_points(c1,c3,c2);
			fprintf(DAT[j].F,"%10f",angle);
			if(angle>180) mywhine("Bad angle");
			angi = floor(angle/(ABINSZ));
			B[j].HOgOb[angi]++;
			/* length1 has not changed.... */
			leni = floor((length1-LBINMIN)/(LBINSZ));
			B[j].HOb2OOH[leni][angi]++;
			/* now, do it all for the O-N-O info... */
			c1=A.m[0][0].r[OLTO[j].r].a[OLTO[j].a].xa[0];
			c2=A.m[0][0].r[NAcH[j].r].a[NAcN[j].a].xa[0];
			c3=A.m[0][0].r[GLYO[j].r].a[GLYO[j].a].xa[0];
			angle=RtoD*get_angle_ABC_points(c1,c2,c3);
			fprintf(DAT[j].F,"%10f",angle);
			if(angle>180) mywhine("Bad angle");
			angi = floor(angle/(ABINSZ));
			B[j].ONO[angi]++;
			leni = floor((nosum-LBINMIN)/(LBINSZ));
			B[j].NOSumONO[leni][angi]++;
			/* when done recording data, print a newline */
			fprintf(DAT[j].F,"\n");
			}

		/** Now, reset everything for the next read */
		for(ai=0;ai<A.na;ai++)
			{
			free(A.a[ai][0].xa);
			A.a[ai][0].nalt=0;
			A.a[ai][0].t=0; /* set this back to zero */
			}	
		test=fgetc(ICF.F);
if((DEBUGLEVEL>2)&&(tsi>5)) exit(0);
		}
	fclose(ICF.F);
	fprintf(LOG.F,"Closing simulation number %d with %d frames\n",i,tsi);
	}


fprintf(LOG.F,"# Total frames %d \n",ttot);
/** for sanity, just do the 1-D stuff first ... */
/** Length bins */
for(k=0;k<8;k++)
	{
	if(k==1) continue;
	if(k==3) continue;
//printf("printing header for 1D file k=%d, whose name is >>%s<<\n",k,B1D[k].N);
	fprintf(B1D[k].F,"#%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n",\
		"Len Center","GalNAc 1","GalNAc 2","GalNAc 3","GalNAc 4","All GalNAc");
	}
for(i=0;i<LBINNUM;i++)
	{
	for(k=0;k<8;k++)
		{
		if(k==1) continue; /* this is an angle file */
		if(k==3) continue; /* this is an angle file */
		fprintf(B1D[k].F,"%11f",LBINMIN+0.5*(2*i+1)*LBINSZ); 
		}
	for(k=0;k<nBtots;k++) Btots[k]=0;
	for(j=0;j<4;j++)
		{
		Btots[0]+=B[j].NOb[i];
		Btots[2]+=B[j].NOg[i];
		Btots[4]+=B[j].NOSUM[i];
		Btots[5]+=B[j].HOb[i];
		Btots[6]+=B[j].HOg[i];
		Btots[7]+=B[j].HOSUM[i];
		fprintf(B1D[0].F,"%10f\t",B[j].NOb[i]/(double)ttot);
		fprintf(B1D[2].F,"%10f\t",B[j].NOg[i]/(double)ttot);
		fprintf(B1D[4].F,"%10f\t",B[j].NOSUM[i]/(double)ttot);
		fprintf(B1D[5].F,"%10f\t",B[j].HOb[i]/(double)ttot);
		fprintf(B1D[6].F,"%10f\t",B[j].HOg[i]/(double)ttot);
		fprintf(B1D[7].F,"%10f\t",B[j].HOSUM[i]/(double)ttot);
		}
	for(k=0;k<8;k++)
		{
		if(k==1) continue; /* this is an angle file */
		if(k==3) continue; /* this is an angle file */
		fprintf(B1D[k].F,"%10f\n",Btots[k]/(double)(4*ttot));
		}
	}
/** Angle bins */
fprintf(B1D[1].F,"#%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n",\
	"Ang Center","GalNAc 1","GalNAc 2","GalNAc 3","GalNAc 4","All GalNAc");
fprintf(B1D[3].F,"#%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n",\
	"Ang Center","GalNAc 1","GalNAc 2","GalNAc 3","GalNAc 4","All GalNAc");
fprintf(B1D[8].F,"#%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n",\
	"Ang Center","GalNAc 1","GalNAc 2","GalNAc 3","GalNAc 4","All GalNAc");
fprintf(B1D[9].F,"#%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n",\
	"Ang Center","GalNAc 1","GalNAc 2","GalNAc 3","GalNAc 4","All GalNAc");
fprintf(B1D[10].F,"#%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n",\
	"Ang Center","GalNAc 1","GalNAc 2","GalNAc 3","GalNAc 4","All GalNAc");
for(i=0;i<ABINNUM;i++)
	{
	fprintf(B1D[1].F,"%11f",ABINMIN+0.5*(2*i+1)*ABINSZ); /* The backbone N-H-O angle bins */
	fprintf(B1D[3].F,"%11f",ABINMIN+0.5*(2*i+1)*ABINSZ); /* The glycosidic N-H-O angle bins */
	fprintf(B1D[8].F,"%11f",ABINMIN+0.5*(2*i+1)*ABINSZ); /* The glycosidic N-H-O angle bins */
	fprintf(B1D[9].F,"%11f",ABINMIN+0.5*(2*i+1)*ABINSZ); /* The glycosidic N-H-O angle bins */
	fprintf(B1D[10].F,"%11f",ABINMIN+0.5*(2*i+1)*ABINSZ); /* The glycosidic N-H-O angle bins */
	for(k=0;k<nBtots;k++) Btots[k]=0;
	for(j=0;j<4;j++)
		{
		Btots[1]+=B[j].NHOb[i];
		Btots[3]+=B[j].NHOg[i];
		Btots[8]+=B[j].ObHOg[i];
		Btots[9]+=B[j].HOgOb[i];
		Btots[10]+=B[j].ONO[i];
		fprintf(B1D[1].F,"%10f\t",B[j].NHOb[i]/(double)ttot);
		fprintf(B1D[3].F,"%10f\t",B[j].NHOg[i]/(double)ttot);
		fprintf(B1D[8].F,"%10f\t",B[j].ObHOg[i]/(double)ttot);
		fprintf(B1D[9].F,"%10f\t",B[j].HOgOb[i]/(double)ttot);
		fprintf(B1D[10].F,"%10f\t",B[j].ONO[i]/(double)ttot);
		}
	fprintf(B1D[1].F,"%10f\n",Btots[1]/(double)(4*ttot));
	fprintf(B1D[3].F,"%10f\n",Btots[3]/(double)(4*ttot));
	fprintf(B1D[8].F,"%10f\n",Btots[8]/(double)(4*ttot));
	fprintf(B1D[9].F,"%10f\n",Btots[9]/(double)(4*ttot));
	fprintf(B1D[10].F,"%10f\n",Btots[10]/(double)(4*ttot));
	}

/** ... then do the 2-D stuff */
for(l=0;l<7;l++)
	{
	fprintf(B2D[l].F,"#%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n",\
		"Len Center","Ang Center","GalNAc 1","GalNAc 2","GalNAc 3","GalNAc 4","All GalNAc");
	}
for(i=0;i<LBINNUM;i++)
	{
	length2=LBINMIN+0.5*(2*i+1)*LBINSZ;
	for(k=0;k<ABINNUM;k++)
		{
		angle=ABINMIN+0.5*(2*k+1)*ABINSZ;
		for(l=0;l<7;l++) fprintf(B2D[l].F,"%10f\t%10f\t",length2,angle);
		for(l=0;l<nBtots;l++) Btots[l]=0;
		for(j=0;j<4;j++)
			{
			Btots[0]+=B[j].Bak2D[i][k];
			Btots[1]+=B[j].Gly2D[i][k];
			Btots[2]+=B[j].HOb2OHO[i][k];
			Btots[3]+=B[j].HOg2OHO[i][k];
			Btots[4]+=B[j].SUM2OHO[i][k];
			Btots[5]+=B[j].HOb2OOH[i][k];
			Btots[6]+=B[j].NOSumONO[i][k];
			fprintf(B2D[0].F,"%10f\t",B[j].Bak2D[i][k]/(double)ttot);
			fprintf(B2D[1].F,"%10f\t",B[j].Gly2D[i][k]/(double)ttot);
			fprintf(B2D[2].F,"%10f\t",B[j].HOb2OHO[i][k]/(double)ttot);
			fprintf(B2D[3].F,"%10f\t",B[j].HOg2OHO[i][k]/(double)ttot);
			fprintf(B2D[4].F,"%10f\t",B[j].SUM2OHO[i][k]/(double)ttot);
			fprintf(B2D[5].F,"%10f\t",B[j].HOb2OOH[i][k]/(double)ttot);
			fprintf(B2D[6].F,"%10f\t",B[j].NOSumONO[i][k]/(double)ttot);
			}
		for(l=0;l<7;l++) fprintf(B2D[l].F,"%10f\n",Btots[l]/(double)(4*ttot));
		}
	for(l=0;l<7;l++) fprintf(B2D[l].F,"\n");
	}

return 0;
}
