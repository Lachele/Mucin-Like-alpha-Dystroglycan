/* concatenate_site_level_rmsd.c begun on 2014-12-31 by BLFoley

	Purpose:  concatenate RMSD data from individual runs
		for site-specific glycan motions,  
		plus collect some statistics on the RMSD's.

		Call from runset/ANALYSIS
		Requires runset/cpptraj_setup.bash
		Leaves blank lines between RMSD sets

	Should be run 4 times, one for each site.

	Notes:

		Will fail if any line in the RMSD file is longer 
			than 2000 characters.
*/

#include <glylib.h>

#define INFOfile       "../cpptraj_setup.bash"
#define SUGROUTpref    "RMSD/Sugr-Bak_rmsd_All2All_"
#define sSUMMARYpref1  "RMSD/RMSD_SB_sAllSUMMARY_"
#define sSUMMARYpref2  "RMSD/RMSD_SB_sRunSUMMARY_"
#define LOGfilePref    "RMSD/RMSD_SB_collection_log_"
#define FrameGap        1000  /* distance to put between frame counters for 
			visual separation when graphing.  Note, this
			makes these frame numbers not meaningful. */

int main(int argc, char *argv[]) 
{
int 	NR=0, /* the number of runs, "NUMRUNS" */
	NS=0, /* the number of structures, "SETSIZE" in the file */
	SETS=0, /* the number of sets, =NUMRUNS/SETSIZE */
	*FRAMES, /* frames in each of the NUMRUNS runs */
	tfrS, /* temporary counters for frames in each run */
	ns,nr, /* counter for NR and NS */
	IndS=0, /* index for output, also total overall frames  */
	GIndS=0, /* gap-index for output (for graphing only)  */
	i; /* generic counter */
char	*IAM, /* name of this runset, from input file */
	line[2001], /* reusable line-getting string */
	*tp1, /* reusable temporary pointer */
	*cp;  /* generic char pointer */
double	tempdouble, /* reusable double */
	**sRunRMSD, /* the NSxNR sets, for getting averages (sugar) */
	*sAllRMSD, /* the overall RMSD average for each structure versus all */
	**sRunRMSD2, /* the NSxNR sets, for getting fluctuations */
	*sAllRMSD2; /* the overall RMSD fluctuations for each structure versus all */
fileset	DAT,  /* the INFO.file */
	IFS,  /* each sugar input rmsd file -- reusable */
	OFS,  /* each sugar all output rmsd file */
	sSUM1,  /* the summary output file */
	sSUM2,  /* the summary output file */
	LOG;  /* the log file */
fileslurp DATfs;

/* Open non-reused files */
DAT.N=strdup(INFOfile); /* don't open me */
/* Read the runset file */
DATfs=slurp_file(DAT);
/* Check command line */
if(strlen(argv[1])!=2) mywhine("Need a two-digit integer as the argument to the function.");
/* Open the log file */
LOG.N=(char*)calloc(strlen(LOGfilePref)+7,sizeof(char));
sprintf(LOG.N,"%s%s.txt",LOGfilePref,argv[1]);
LOG.F=myfopen(LOG.N,"w");
fprintf(LOG.F,"# Log file for summarize_Sugr-Bak_rmsd for site %s begun at %s \n",argv[1],mytime("longpretty"));
/* read data file, also write contents to log */
fprintf(LOG.F,"#\n# The contents of the input file follow.\n#\n");
for(i=0;i<DATfs.n;i++)
	{
	cp=NULL;
	fprintf(LOG.F,"#    %s",DATfs.L[i]);
	cp=strstr(DATfs.L[i],"IAM");
	if(cp!=NULL)
		{
		IAM=NULL;
		cp=strchr(cp,'"');
		cp++;
		if(cp[1]=='V') IAM=strdup("d4g");
		if(cp[1]=='M') IAM=strdup("d4m");
		if(cp[1]=='r') mywhine("This program isn't to be run for the unglycosylated peptide.");
		if(IAM==NULL) mywhine("Can't determine runset identity\n");
		}
	cp=NULL;
	cp=strstr(DATfs.L[i],"MAXRUNS");
	if(cp!=NULL)
		{
		cp=strchr(cp,'=');
		if(cp!=NULL)
			{
			cp++;
			if(sscanf(cp,"%d",&NR)!=1) mywhine("Can't determine NR\n");
			}
		}
	cp=NULL;
	cp=strstr(DATfs.L[i],"SETSIZE");
	if(cp!=NULL)
		{
		cp=strchr(cp,'=');
		if(cp!=NULL) 
			{
			cp++;
			if(sscanf(cp,"%d",&NS)!=1) mywhine("Can't determine NS\n");
			}
		}
	}
if(NR<=0) mywhine("NR is less than or equal to zero!");
if(NS<=0) mywhine("NS is less than or equal to zero!");
if((NR%NS)!=0) mywhine("NR is not a multiple of NS!");
SETS=NR/NS;
fprintf(LOG.F,"# The runset identity is %s \n",IAM);
fprintf(LOG.F,"NR is %d ; NS is %d ; SETS is %d\n",NR,NS,SETS);

/* continue opening files & initialize some */
sSUM1.N=(char*)calloc(strlen(sSUMMARYpref1)+7,sizeof(char));
sprintf(sSUM1.N,"%s%s.txt",sSUMMARYpref1,argv[1]);
sSUM1.F=myfopen(sSUM1.N,"w");
sSUM2.N=(char*)calloc(strlen(sSUMMARYpref2)+7,sizeof(char));
sprintf(sSUM2.N,"%s%s.txt",sSUMMARYpref2,argv[1]);
sSUM2.F=myfopen(sSUM2.N,"w");
OFS.N=(char*)calloc(strlen(SUGROUTpref)+7,sizeof(char));
sprintf(OFS.N,"%s%s.dat",SUGROUTpref,argv[1]);
OFS.F=myfopen(OFS.N,"w");
fprintf(OFS.F,"# Concatenation of all RMSD files written by cpptraj,\n# with blank lines between each.\n#\n");

FRAMES=(int*)calloc(NR,sizeof(int));


/* Allocate space for the statistics arrays and for the reusable files */
IFS.N=(char*)calloc(strlen("RMSD/S_Sugr-Bak_rmsd_tzzzzzz_r-all.dat")+1,sizeof(char));
sAllRMSD=(double*)calloc(NS,sizeof(double*));
sAllRMSD2=(double*)calloc(NS,sizeof(double*));
sRunRMSD=(double**)calloc(NS,sizeof(double*));
sRunRMSD2=(double**)calloc(NS,sizeof(double*));
for(i=0;i<NS;i++) 
	{
	sRunRMSD[i]=(double*)calloc(NR,sizeof(double));
	sRunRMSD2[i]=(double*)calloc(NR,sizeof(double));
	}

IndS=GIndS=0; /* index and gap-index for output */
for(nr=0;nr<NR;nr++) 
	{ /* for each run (nr) */
	/* open the rmsd files (back and sugr) & add initial comment line */
	sprintf(IFS.N,"RMSD/S_Sugr-Bak_rmsd_t%d_%s_r-all.dat",nr+1,argv[1]);
	IFS.F=myfopen(IFS.N,"r");
	fprintf(OFS.F,"# Printing RMSD's for run number %d \n",nr+1);
	/* Sugar */
	tfrS=0;
	while(fgets(line,2000,IFS.F)!=NULL)
		{ /* for each line in the file */
		if(line[0]=='#')
			{ /* if this is a title or comment line, just print it and move on */
			fprintf(OFS.F,"# Index       GapIndex      %s",line);
			continue;
			}
		IndS++;
		GIndS++;
		tfrS++;
		tp1=line;
		tp1+=strspn(tp1," ");
		sscanf(tp1,"%d",&i);
		if(i!=tfrS) mywhine("mismatch between frame # in file and expected number");
		tp1+=strcspn(tp1," ");
		/* print the relevant entries to the concatenated files */
		fprintf(OFS.F,"%13d %13d %s",IndS,GIndS,line);
		/* print a newline to the two collected rmsd files */
		//fprintf(OFS.F,"\n");
		/* Now, record info for statistics */
		for(ns=0;ns<NS;ns++)
			{ /* for each of the NS initial structures (ns) */
			tp1+=strspn(tp1," ");
			i=sscanf(tp1,"%lf",&tempdouble);
			if(i!=1) mywhine("problem reading rmsd value for backbone");
			tp1+=strcspn(tp1," ");
			/* add the value and value squared to the arrays */
			sRunRMSD[ns][nr]+=tempdouble;
			sAllRMSD[ns]+=tempdouble;
			sRunRMSD2[ns][nr]+=tempdouble*tempdouble;
			sAllRMSD2[ns]+=tempdouble*tempdouble;
			} /* close for each initial structure */
		}/* close for each line in the file */
	/* print a newline to the two collected rmsd files */
	fprintf(OFS.F,"\n");
	FRAMES[nr]=tfrS; /* if weird memory trouble, look here...*/
	/* print info about the contents & close rmsd input files */
	fprintf(OFS.F,"# Index       GapIndex      Frame in this run   (rmsds for each initial struct -->)\n");
	GIndS+=FrameGap;
	fclose(IFS.F);
	} /* close for each run */
fclose(OFS.F);

if(IndS==0) mywhine("total overall frames is zero!");
/* calculate statistics and save info to the LOG file */
fprintf(LOG.F,"============================================================\n");
fprintf(LOG.F,"=========  Information regarding numbers of frames =========\n");
fprintf(LOG.F,"============================================================\n");
fprintf(LOG.F,"Structure Index    Frames Overall   ");
for(nr=0;nr<NR;nr++) fprintf(LOG.F,"      Run %2d",nr+1);
fprintf(LOG.F,"\n");
for(ns=0;ns<NS;ns++)
	{
	fprintf(LOG.F,"%15d   %15d   ",ns+1,IndS);
	sAllRMSD2[ns]-=(sAllRMSD[ns]*sAllRMSD[ns]/(double)IndS);
	sAllRMSD[ns]/=(double)IndS;
	sAllRMSD2[ns]/=(double)IndS;
	sAllRMSD2[ns]=sqrt(sAllRMSD2[ns]);
for(nr=0;nr<NR;nr++)
	{
	fprintf(LOG.F,"%12d",FRAMES[nr]);
	sRunRMSD2[ns][nr]-=(sRunRMSD[ns][nr]*sRunRMSD[ns][nr]/(double)FRAMES[nr]);
	sRunRMSD[ns][nr]/=(double)FRAMES[nr];
	sRunRMSD2[ns][nr]/=(double)FRAMES[nr];
	sRunRMSD2[ns][nr]=sqrt(sRunRMSD2[ns][nr]);
	}
	fprintf(LOG.F,"\n");
	}

fprintf(sSUM1.F,"# RMSD summary data for each initial structure versus all runs \n");
fprintf(sSUM2.F,"# RMSD summary data for each initial structure versus each run \n");
fprintf(sSUM1.F,"# %20s %20s %20s \n","Structure Index","Average RMSD","RMSD Fluctuations");
fprintf(sSUM2.F,"# %20s %20s %20s %20s \n","Structure Index","Run Index","Average RMSD","RMSD Fluctuations");
/* write info to the summary files */
for(ns=0;ns<NS;ns++)
	{
	fprintf(sSUM1.F,"  %20d %20.4f %20.4f \n",ns+1,sAllRMSD[ns],sAllRMSD2[ns]);
for(nr=0;nr<NR;nr++)
	{
	fprintf(sSUM2.F,"  %20d %20d %20.4f %20.4f \n",ns+1,nr+1,sRunRMSD[ns][nr],sRunRMSD2[ns][nr]);
	}
	}
return 0;
}
