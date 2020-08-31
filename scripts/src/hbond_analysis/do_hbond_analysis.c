/** file do_hbond_analysis.c

Purpose:  This program does some HBond analysis that is not possible in (cp)ptraj.

More info:  

	I need to be able to correlate H-bonding to overall peptide length.  So, I
	have to write a program to extract the relevant data.  

	This program requires the following:

		* A list of H-Bonds provided by (cp)ptraj.  Because I don't feel like
			rewriting all that.
		* The number of the simulation directories for the runset
		* That it be run from the runset/ANALYSIS/HBOND directory

	This program will automatically do the following:

		* Find and read in the parm7 and mdcrd files for a given runset.

	It will provide, for each H-bond from the list that is found in the trajectory:

		HBond index: its position, starting from 1, in the original list
		Sim #:  the index corresponding to the simulation number
		Frame #:  the frame number in the trajectory
		Bond type #: an index describing the type of bond
				0  Glycan to its nearest amino acid
				1  Glycan to another Glycan
				2  Glycan to some other amino acid
				3  Amino acid to another amino acid
				4  Glycan to itself
				5  Amino acid to itself
		Bond length:  the heavyatom-heavyatom distance
		Bond angle:  the heavy-H-heavy angle
		N-N length:  length between the two terminal N's

*/

#include <glylib.h>

#define USAGE "\n\
        hbond_analysis bond_file PREFIX number_sims \n\
                Where:\n\
                    bond_file contains a list of all bonds to check\n\
                    Prefix is a prefix for output files\n\
                    number_sims is the number of simulations for this runset\n\
"
#define LENGTH  3.0  /** max heavy-atom heavy-atom distance */
#define ANGLE  PI*100.0/180.0 /** minimum heavy-H-heavy angle to consider */
#define OFSUFFIX ".txt"
typedef struct {
	molindex A; /**< Acceptor */
	molindex H; /**< Hydrogen */
	molindex D; /**< Donor  */
	int type; /**< type as define in the headers */
	int n; /**< the total number of this type of H-bond found */
	double NN; /**< average N-N distance */
	int *SF; /**< bonds found per each simulation */
	double *SNN; /**< N-N distance per each simulation */
} hbondset;


int main (int argc, char *argv[])
{
int ai, /**< atom index */
    tsi, /**< trajectory set index */
    i,j, /**< generic counters */
    ttot,  /** total number of trajectory frames */
    nsim, /**< number of simulations */
    prefl, /**< strlen for the PREFIX */
    nHB; /**< number of HBonds found in file */
int test, /**< for file status */
    *SFs, /**< Number of frames in eac sim */
    isanglegood, /** 0=yes 1=no */
    isdistancegood, /** 0=yes 1=no */
    acceptorisglycan, /** 0=yes 1=no */
    donorisglycan; /** 0=yes 1=no */
assembly A;
hbondset *B;
fileset PF,/**< prmtop file */
	ICF, /**< trajcrd file in */
	HBF, /**< H-Bonds input file */
	*OF, /**< array of H-Bond analysis files (one per type) */
	SOF, /**< output information per simulation */
	LOG; /**< log file */
char 	*PREF, /**< Prefix for output files */
	/** Temporary pointers for parsing the HBond atom info */
	*tmp,*arN,*arn,*aaN,*hrN,*hrn,*haN,*drN,*drn,*daN,
	line[501];
double	angle,
	length,
	NN;
coord_3D  c1, c2, c3;

//printf("1\n");

if(argc!=4) myusage(USAGE);

/** Do some initializations and such */
prefl=strlen(argv[2]);
PREF=&(argv[2][0]);
if(sscanf(argv[3],"%d",&nsim)!=1) mywhine("coudn't get the number of simulations");
/** Open the file containing H-bonds */
HBF.N=strdup(argv[1]);
HBF.F=myfopen(HBF.N,"r");
nHB=cscan_file(HBF.F,'\n')-1; /**< minus one for the header line */
/** Open the log file and write initial information */
LOG.N=(char*)calloc(prefl+strlen("_logfile.txt")+1,sizeof(char));
sprintf(LOG.N,"%s_logfile.txt",argv[2]);
LOG.F=myfopen(LOG.N,"w");
fprintf(LOG.F,"# Starting H-Bond vs N-N length analysis for these values:\n");
fprintf(LOG.F,"#\tbond file = \"%s\"\n",argv[1]);
fprintf(LOG.F,"#\tPREFIX = \"%s\"\n",argv[2]);
fprintf(LOG.F,"#\tnumber_sims = %s \n",argv[3]);
fprintf(LOG.F,"#\tlogfile = \"%s\" (this file)\n#\n",LOG.N);
fprintf(LOG.F,"#\tnumber H-Bonds to consider = %d \n#\n",nHB);
fprintf(LOG.F,"# HBond types are as follows: \n");
fprintf(LOG.F,"#        0  Glycan to its nearest amino acid \n");
fprintf(LOG.F,"#        1  Glycan to another Glycan \n");
fprintf(LOG.F,"#        2  Glycan to some other amino acid \n");
fprintf(LOG.F,"#        3  Amino acid to another amino acid \n");
fprintf(LOG.F,"#        4  Glycan to itself \n");
fprintf(LOG.F,"#        5  Amino acid to itself \n");
/** Load the topology file */
PF.N=strdup("../../input/Single.parm7");
A=load_amber_prmtop(PF); 
if(A.nm!=1) mywhine("problem with topology file read");
/** Parse and record information about the hydrogen bonds */
/** Make space for the HBonding information */
B=(hbondset*)calloc(nHB,sizeof(hbondset));
SFs=(int*)calloc(nsim,sizeof(int));
/** Open the output HBOND info files */
OF=(fileset*)calloc(nHB,sizeof(fileset));
for(i=0;i<nHB;i++)
	{
	B[i].SF=(int*)calloc(nsim,sizeof(int));
	B[i].SNN=(double*)calloc(nsim,sizeof(double));
	OF[i].N=(char*)calloc(prefl+strlen(OFSUFFIX)+9,sizeof(char));
	sprintf(OF[i].N,"%s_HB_%04d%s",PREF,i+1,OFSUFFIX);
	fgets(line,500,HBF.F);
	if(line[0]=='#') fgets(line,500,HBF.F);
	OF[i].F=myfopen(OF[i].N,"w");
	fprintf(OF[i].F,"# Bonding information for index %d -- %s",i+1,line);
	fprintf(OF[i].F,"#%10s%10s%10s%10s%10s%10s%10s\n"," Index","Sim #","Frame","Type","Length","Angle","N-N dist");
	/* Save HBond information */
	/* The following is ugly, but should work...*/
		tmp=strdup(line);
		arN=&(tmp[0]);
		arn=strchr(arN,'_');
		arn[0]='\0';
		arn++; 
		aaN=strchr(arn,'@');
		aaN[0]='\0';
		aaN++;
		hrN=strchr(aaN,' ');
		hrN[0]='\0';
		hrN++;
		hrn=strchr(hrN,'_');
		hrn[0]='\0';
		hrn++;
		haN=strchr(hrn,'@');
		haN[0]='\0';
		haN++;
		drN=strchr(haN,' ');
		drN[0]='\0';
		drN++;
		drn=strchr(drN,'_');
		drn[0]='\0';
		drn++;
		daN=strchr(drn,'@');
		daN[0]='\0';
		daN++;
		daN[strlen(daN)-1]='\0';
//free(tmp);
	/* get the molecule indices for the three atoms */
	B[i].A.m=B[i].H.m=B[i].D.m=0; /**< should only be one molecule */
	sscanf(arn,"%d",&B[i].A.r);
	B[i].A.r--;
	if(strcmp(A.m[0][0].r[B[i].A.r].N,arN)!=0) mywhine("Acceptor residue names don't match");
	sscanf(hrn,"%d",&B[i].H.r);
	B[i].H.r--;
	if(strcmp(A.m[0][0].r[B[i].H.r].N,hrN)!=0) mywhine("Hydrogen residue names don't match");
	sscanf(drn,"%d",&B[i].D.r);
	B[i].D.r--;
	if(strcmp(A.m[0][0].r[B[i].D.r].N,drN)!=0) mywhine("Donor residue names don't match");
	/* Find the atom indices */
	B[i].A.a=B[i].H.a=B[i].D.a=-1;
	for(j=0;j<A.m[0][0].r[B[i].A.r].na;j++)
		{
		if(strcmp(A.m[0][0].r[B[i].A.r].a[j].N,aaN)==0)
			{
			B[i].A.a=j;
			break;
			}
		}
	for(j=0;j<A.m[0][0].r[B[i].H.r].na;j++)
		{
		if(strcmp(A.m[0][0].r[B[i].H.r].a[j].N,haN)==0)
			{
			B[i].H.a=j;
			break;
			}
		}
	for(j=0;j<A.m[0][0].r[B[i].D.r].na;j++)
		{
		if(strcmp(A.m[0][0].r[B[i].D.r].a[j].N,daN)==0)
			{
			B[i].D.a=j;
			break;
			}
		}
	if(B[i].A.a==-1) mywhine("Could not find acceptor atom index.");
	if(B[i].H.a==-1) mywhine("Could not find hydrogen atom index.");
	if(B[i].D.a==-1) mywhine("Could not find donor atom index.");
	/* Find the hbond type per: 
				0  Glycan to its amino acid or nearest backbone
				1  Glycan to another Glycan
				2  Glycan to some other amino acid
				3  Amino acid to another amino acid
				4  Glycan to itself
				5  Amino acid to itself
	*/
	acceptorisglycan=donorisglycan=1;
	B[i].type=-1;
	if((strcmp(arN,"0VA")==0)||(strcmp(arN,"0MA")==0)) acceptorisglycan=0;
	if((strcmp(drN,"0VA")==0)||(strcmp(drN,"0MA")==0)) donorisglycan=0;
	if((acceptorisglycan==0)&&(donorisglycan==0)) /* both are glycans */
		{
		if(B[i].A.r==B[i].D.r) B[i].type=4;
		else B[i].type=1;
		}
	else  if((acceptorisglycan!=0)&&(donorisglycan!=0)) /* both are amino acids */
		{
			{
			if(B[i].A.r==B[i].D.r) B[i].type=5;
			else B[i].type=3; 
			}
		}
	else   /* one is glycan, one is amino acid */
		{
		if(abs(B[i].A.r-B[i].D.r)==8) B[i].type=0;
		else if (abs(B[i].A.r-B[i].D.r)==7) 
			{
			if((strcmp(aaN,"N")==0)||(strcmp(aaN,"N")==0)) B[i].type=0;
			else if((strcmp(haN,"H")==0)||(strcmp(haN,"H")==0)) B[i].type=0;
			else if((strcmp(daN,"N")==0)||(strcmp(daN,"N")==0)) B[i].type=0;
			else B[i].type=2;
			}
		else B[i].type=2;
		}
	if(B[i].type==-1) mywhine("no type found for H-bond");
	}

ttot=0;
ICF.N=(char*)calloc(strlen("../../xx/prod_all_fixed.crd")+1,sizeof(char));
for(i=1;i<=nsim;i++) /* note!!  not starting at zero!! */
	{
	/** Open the input trajcrd file */
	sprintf(ICF.N,"../../%d/prod_all_fixed.crd",i); /**< open the new trajectory file */
	ICF.F=myfopen(ICF.N,"r");
	for(j=0;j<nHB;j++)
		{ 
		fprintf(OF[j].F,"## Starting information for simulation # %d\n",i);
		}
	tsi=0;
	test=fgetc(ICF.F);
	while(test != EOF){
		ungetc(test,ICF.F);
		tsi++;
		/** Load the first/next frame in the coordinate file */
		add_trajcrds_to_prmtop_assembly(ICF,&A,'c',0);
		ttot++;
		/** For each defined HBond */
		for(j=0;j<nHB;j++)
			{ 
			/** Check that the bond exists */
			isanglegood=1;
			c1=A.m[0][0].r[B[j].A.r].a[B[j].A.a].xa[0];
			c2=A.m[0][0].r[B[j].H.r].a[B[j].H.a].xa[0];
			c3=A.m[0][0].r[B[j].D.r].a[B[j].D.a].xa[0];
			angle=get_angle_ABC_points(c1,c2,c3);
			if(angle>=ANGLE) isanglegood=0;
			isdistancegood=1;
			length=get_magnitude(coord_to_vec(subtract_coord(c1,c3)));
			if(length<=LENGTH) isdistancegood=0;
			/** If so, calculate N-N distance and save info */
			if((isdistancegood==0)&&(isanglegood==0))
				{
				c1=A.m[0][0].r[3].a[0].xa[0]; /* N in OLT 4 */
				c2=A.m[0][0].r[7].a[0].xa[0]; /* N in LYS 8 */
				NN=get_magnitude(coord_to_vec(subtract_coord(c1,c2)));
				fprintf(OF[j].F,"%10d%10d%10d%10d%10.2f%10.4f%10.3f\n",\
					j+1,i,tsi,B[j].type,length,angle,NN);
				B[j].SF[i-1]++;
				B[j].SNN[i-1]+=NN;
				B[j].NN+=NN;
				B[j].n++;
				SFs[i-1]++;
				}
			}

		/** Now, reset everything for the next read */
		for(ai=0;ai<A.na;ai++)
			{
			free(A.a[ai][0].xa);
			A.a[ai][0].nalt=0;
			A.a[ai][0].t=0; /* set this back to zero */
			}	
		test=fgetc(ICF.F);
		}
	fclose(ICF.F);
	}

fprintf(LOG.F,"#\n#\n#======================= Per HBond statistics  =====================\n#\n");
fprintf(LOG.F,"# Total number of trajectory frames scanned:  %d\n",ttot);
fprintf(LOG.F,"#%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n","Index","Type","Acceptor","Hydrogen","Donor   ","Frames","Fraction","Avg N-N");
for(i=0;i<nHB;i++)
	{
	NN=0;
	if(B[i].n>0) NN=B[i].NN/(double)B[i].n;
	fprintf(LOG.F,"%4d\t%4d\t%s_%d@%-3s\t%s_%d@%-3s\t%s_%d@%-3s\t%6d\t%8.3f\t%8.3f\n",i+1,B[i].type,\
		A.m[0][0].r[B[i].A.r].N,A.m[0][0].r[B[i].A.r].n,A.m[0][0].r[B[i].A.r].a[B[i].A.a].N,\
		A.m[0][0].r[B[i].H.r].N,A.m[0][0].r[B[i].H.r].n,A.m[0][0].r[B[i].H.r].a[B[i].H.a].N,\
		A.m[0][0].r[B[i].D.r].N,A.m[0][0].r[B[i].D.r].n,A.m[0][0].r[B[i].D.r].a[B[i].D.a].N,\
		B[i].n,(double)B[i].n/(double)ttot,NN);
	}

SOF.N=(char*)calloc(strlen(PREF)+strlen("_SIM_xx.txt")+1,sizeof(char));
for(i=1;i<=nsim;i++) /* note!!  not starting at zero!! */
	{
	sprintf(SOF.N,"%s_SIM_%d.txt",PREF,i); 
	SOF.F=myfopen(SOF.N,"w");
	fprintf(SOF.F,"# HBonds in Simulation Number %d \n",i);
	fprintf(SOF.F,"#%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n","Index","Type","Acceptor","Hydrogen","Donor   ","Frames","Fraction","Avg N-N");
	for(j=0;j<nHB;j++)
		{
		if(B[j].SF[i-1]>0)
			{
			NN=B[j].SNN[i-1]/(double)B[j].SF[i-1];
			fprintf(SOF.F,"%4d\t%4d\t%s_%d@%-3s\t%s_%d@%-3s\t%s_%d@%-3s\t%6d\t%8.3f\t%8.3f\n",j+1,B[j].type,\
				A.m[0][0].r[B[j].A.r].N,A.m[0][0].r[B[j].A.r].n,A.m[0][0].r[B[j].A.r].a[B[j].A.a].N,\
				A.m[0][0].r[B[j].H.r].N,A.m[0][0].r[B[j].H.r].n,A.m[0][0].r[B[j].H.r].a[B[j].H.a].N,\
				A.m[0][0].r[B[j].D.r].N,A.m[0][0].r[B[j].D.r].n,A.m[0][0].r[B[j].D.r].a[B[j].D.a].N,\
				B[j].SF[i-1],(double)B[j].SF[i-1]/(double)SFs[i-1],NN);
			}
		}
	}

return 0;
}
