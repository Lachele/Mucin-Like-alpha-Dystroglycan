/** file do_equil_water_check.c

Purpose:  This program does some HBond analysis that is not possible in (cp)ptraj.

		Currently, cpptraj will not do solute-solvent H-bonding analysis,
			and certainly does not look for bridge-type H-bonds.

		The program does this:

			* Searches for water-mediated H-bonds between the 
				backbone H and the GalNAc's NAc H

More info:  

	I need to be able to find instances where there might be water-mediated
		H-Bonding between the GalNAc N-H and the backbone H.  This seems
		very unlikely, but I'll look for it in the equilibration data.
		Waters were not saved in the production data, so we have to look
		in the equilibration trajectories.  

	This program requires the following:

		* The number of the simulation directories for the runset
		* That it be run from the d4g/ANALYSIS/WAT_HBOND directory
		* That the equilibration mdcrd's will be named and be in 
			the location indicated in the defines below
		* The coordinates be pre-wrapped

	This program will automatically do the following:

		* Find and read in the parm7 and mdcrd files for a given runset.
		* Print a version of the collected, all 32 runs, mdcrd file without waters.
		* For each NAc H and for each backbone H, it will:
			o Search for water oxygens that are within H-Bonding 
				distance (wrapping coordinates if necessary)
			o Check each for proper angles 
			o If an H-bond is found, it will:
				> Check for possibility of mediation to the 
					other atom
				> Print information to a file
			o If mediation is found, it will:
				> Print information to another file
				> Print that frame **WITH** the bridging water
			o If no H-bond is found, it will:
				> Print info about the closest O for each H
		* Check HN-Hbak and OG-Obak distances.
			o If O-O < 4   &&  site is NOT #4
				--or--
			o If site is #4   &&  H-H < 5  &&  O-O < 4
				> print coords to a separate file -- without waters
			o Same criteria as before, but print to yet another file 
				if there is not a bridging water.

	Files:

		Here, i=1..4 and refers to the specific glycan 

		* Information for all bridged H-bonds found 

			Files:  Bridge_bonds_i.dat

			Index    Sim #    frame #   Hb...O  Hg...O  O...Hb--N  O...Hg--N   O Resnum   O Atomnum

		* Coordinates for all bridged H-bonds found **PLUS** the bridging water

			Files:  Bridge_bonds_i.mdcrd

		* Coordinates for all 4-way interactions

			Files:  4-Way_ALl_i.mdcrd

		* Coordinates for 4-Ways without bridging bonds

			Files:  4-Way_no_bridge_i.mdcrd

		* Information for all H-bonds to either H 
			This will include info for that O to the other H/N

			Files:  Plain_bonds_g_i.dat, Plain_bonds_b_i.dat

			Sim #    frame #   Hb...O  Hg...O  O...Hb--N  O...Hg--N   O Resnum   O Atomnum

		* Information about the closest O to each H where there are no H-bonds

			Files:  Closest_O_g_i.dat, Closest_O_b_i.dat

			Sim #    frame #   distance   O Resnum   O Atomnum

		* Counts of frames per simulation that have bridged bonds and overall

			File:  Bridged_Bonds_Summary.txt
					
*/

#include <glylib.h>

/* these are not somehow in the molecule.h defines... */
void deallocateBoxinfo(boxinfo *bi);
void deallocateFullAssembly(assembly *a);

#define USAGE "\n\
        mediated_analysis PREFIX \n\
                Where:\n\
                    Prefix is a prefix for output files\n\
"
#define LENGTH  2.5  /**< max hydrogen - water O distance */
#define CLOSE  3.5  /**< Any O farther than this away from a hydrogen isn't close */
#define ANGLE  PI*100.0/180.0 /**< minimum heavy-H-heavy angle to consider */
#define MDCRDLOC "../RADIAL/equil_all_"
#define MDCRDSUF ".mdcrd"
#define PARMLOC  "../../input/"
#define PARMSUF  "_SolCl.parm7"
#define NATOMS  259  /**< number of atoms in solute (just the glycopeptide) */
#define NSIM     32 /**< Number of simulations */

typedef struct {
	molindex A; /**< Acceptor */
	molindex H; /**< Hydrogen */
	molindex D; /**< Donor  */
	double   d; /**< H . . . X distance */
	double   a; /**< Z-H . . .X angle */
	char	good; /**< is this actually an H-bond? (y/n) */
} hbondset;

int main (int argc, char *argv[])
{
int m,r,a, /**< molecule, residue and atom */
    b, /**< index for box info */
    ai, /**< atom index just for coordinate printing*/
    resnum, /**< residue number (reusable) */
    xfi, /**< line termination index for coordinate printing */
    tsi, /**< trajectory set index */
    i,j, /**< generic counters */
    ttot,  /** total number of trajectory frames */
    bbtot[4], /**< total number of bridging bonds found */
    prefl, /**< strlen for the PREFIX */
    OWgcheck[4], /**< check need to do dist calc */
    OWbcheck[4], /**< check need to do dist calc */
    Is4Way[4], /**< reusable flag to say we have a 4-way situation */
    IsBridge[4], /**< reusable flag to say we have a bridge situation */
    nBr[NSIM][4], /**< counts of Bridging waters */
    n4W[NSIM][4], /**< counts of all 4-Ways */
    n4W_noB[NSIM][4], /**< counts of 4-Ways without bridging  */
    nBr_no4[NSIM][4], /**< counts of Bridges without 4-Ways (these are not expected) */
    frames[NSIM], /**< frames found in each sim (should be 900 each) */
    test; /**< for file status */
intset iminHb[4],imaxHb[4],iminHg[4],imaxHg[4];
assembly A;
atom 	*Hb[4], /**< convenience pointers for: the backbone H */
	*Hg[4], /**< the glycan H */
	*Nb[4], /**< the backbone N */
	*Ng[4], /**< the glycan N */
	*Ob[4], /**< the backbone O */
	*Og[4], /**< the glycan O */
	*OWb[4], /**< the backbone's nearest water O */
	*OWg[4], /**< the glycan's nearest water O */
	*Ocurr, /**< the O being currently considered */
	*WAT[3]; /**< the three atoms in the water, in proper order, for coding simplicity */
residue *rcurr; /* for convenience in finding the bridging water coords */
hbondset HBSb[4],HBSg[4]; /**< for backbone and glycan, for each glycan/backbone set */
fileset PF,/**< prmtop file */
	ICF, /**< trajcrd file in */
	BOF[4], /**< bridged bond output information  */
	Traj, /**< trajectory of all frames minus water -- for external analysis (printing while we're here anyway) */
	TOF[4], /**< trajectory output per glycan for bridged bonds + WATER */
	T4W[4], /**< trajectory output per glycan for all 4-Way */
	T4W_noB[4], /**< trajectory output per glycan for 4-Way without Bridge */
	TBr_no4[4], /**< trajectory output per glycan for 4-Way without Bridge */
	HOFb[4], /**< one-way H-bond info for the backbone */
	HOFg[4], /**< one-way H-bond info for the glycan */
	COFb[4], /**< closest O info for the backbone */
	COFg[4], /**< closest O info for the glycan */
	SUM,    /**< Summary file for this run */
	LOG; /**< log file */
char 	*PREF; /**< Prefix for output files */
double	closestOdb[4], /**< for finding the closest backbone O if there is no H-bond */
	closestOdg[4], /**< for finding the closest glycan O if there is no H-bond */
	HH=0, /**< NAc-H to Bak-H, reusable */
	OO=0; /**< Og to Ob, reusable */
coord_3D  Ocb,Ocg,minHg[4],maxHg[4],minHb[4],maxHb[4];
amber_prmtop *AP;

//printf("1\n");

if(argc!=2) myusage(USAGE);

/** Do some initializations and such */
initialize_assembly(&A);
prefl=strlen(argv[1]);
PREF=&(argv[1][0]);
/** Open the log file and write initial information */
LOG.N=(char*)calloc(prefl+strlen("_logfile.txt")+1,sizeof(char));
sprintf(LOG.N,"%s_logfile.txt",argv[1]);
LOG.F=myfopen(LOG.N,"w");
fprintf(LOG.F,"# Starting H-Bond vs N-N length analysis for these values:\n");
fprintf(LOG.F,"#\tPREFIX = \"%s\"\n",argv[1]);
fprintf(LOG.F,"#\tnumber_sims = %s \n",argv[2]);
fprintf(LOG.F,"#\tlogfile = \"%s\" (this file)\n#\n",LOG.N);
/** Open the summary file and print initial information */
SUM.N=(char*)calloc(prefl+strlen("_summary.txt")+1,sizeof(char));
sprintf(SUM.N,"%s_summary.txt",argv[1]);
SUM.F=myfopen(SUM.N,"w");
fprintf(SUM.F,"# Summary information about bridged H-bonding between Hbak and HNac\n#\n");
/* trajectory output per glycan for bridged bonds */
Traj.N=(char*)calloc(prefl+strlen("_all_frames_NoWAT.mdcrd")+1,sizeof(char));
sprintf(Traj.N,"%s_all_frames_NoWAT.mdcrd",PREF);
Traj.F=myfopen(Traj.N,"w");
fprintf(Traj.F,"Trajectory of all frames without waters\n");
/** Open the per-location output files */
for(j=0;j<4;j++)
	{
	/* bridged bond output information  */
	BOF[j].N=(char*)calloc(prefl+strlen("_Bridge_bonds_i.dat")+1,sizeof(char));
	sprintf(BOF[j].N,"%s_Bridge_bonds_%d.dat",PREF,j+1);
	BOF[j].F=myfopen(BOF[j].N,"w");
	fprintf(BOF[j].F,"%10s%10s%10s%12s%12s%12s%12s%10s%10s\n","#Index","Sim #","frame #","Hb...O","Hg...O","O...Hb--N","O...Hg--N","O Resnum","O Atomnum");
	/* trajectory output per glycan for bridged bonds with WATER */
	TOF[j].N=(char*)calloc(prefl+strlen("_Bridge_bonds_i.mdcrd")+1,sizeof(char));
	sprintf(TOF[j].N,"%s_Bridge_bonds_%d.mdcrd",PREF,j+1);
	TOF[j].F=myfopen(TOF[j].N,"w");
	fprintf(TOF[j].F,"Trajectory of bridging waters\n");
	/* trajectory output per glycan for all 4-way interactions */
	T4W[j].N=(char*)calloc(prefl+strlen("_4Ways_i.mdcrd")+1,sizeof(char));
	sprintf(T4W[j].N,"%s_4Ways_%d.mdcrd",PREF,j+1);
	T4W[j].F=myfopen(T4W[j].N,"w");
	fprintf(T4W[j].F,"Trajectory of 4-Way interactions\n");
	/* trajectory output per glycan for 4-way interactions without bridged bonds */
	T4W_noB[j].N=(char*)calloc(prefl+strlen("_4Way-noBridge_i.mdcrd")+1,sizeof(char));
	sprintf(T4W_noB[j].N,"%s_4Way-noBridge_%d.mdcrd",PREF,j+1);
	T4W_noB[j].F=myfopen(T4W_noB[j].N,"w");
	fprintf(T4W_noB[j].F,"Trajectory of 4-Ways without bridging waters\n");
	/* trajectory output per glycan for 4-way interactions without bridged bonds */
	TBr_no4[j].N=(char*)calloc(prefl+strlen("_Bridge-no4Way_i.mdcrd")+1,sizeof(char));
	sprintf(TBr_no4[j].N,"%s_Bridge-no4Way_%d.mdcrd",PREF,j+1);
	TBr_no4[j].F=myfopen(TBr_no4[j].N,"w");
	fprintf(TBr_no4[j].F,"Trajectory of Bridging bonds, without 4-Ways WITH bridging water\n");
	/* one-way H-bond info for the backbone */
	HOFb[j].N=(char*)calloc(prefl+strlen("_Plain_bonds_b_i.dat")+1,sizeof(char));
	sprintf(HOFb[j].N,"%s_Plain_bonds_b_%d.dat",PREF,j+1);
	HOFb[j].F=myfopen(HOFb[j].N,"w");
	fprintf(HOFb[j].F,"%10s%10s%12s%12s%12s%12s%10s%10s\n","#Sim #","frame #","Hb...O","Hg...O","O...Hb--N","O...Hg--N","O Resnum","O Atomnum");
	/* one-way H-bond info for the glycan */
	HOFg[j].N=(char*)calloc(prefl+strlen("_Plain_bonds_g_i.dat")+1,sizeof(char));
	sprintf(HOFg[j].N,"%s_Plain_bonds_g_%d.dat",PREF,j+1);
	HOFg[j].F=myfopen(HOFg[j].N,"w");
	fprintf(HOFg[j].F,"%10s%10s%12s%12s%12s%12s%10s%10s\n","#Sim #","frame #","Hb...O","Hg...O","O...Hb--N","O...Hg--N","O Resnum","O Atomnum");
	/* closest O info for the backbone */
	COFb[j].N=(char*)calloc(prefl+strlen("_Closest_O_b_i.dat")+1,sizeof(char));
	sprintf(COFb[j].N,"%s_Closest_O_b_%d.dat",PREF,j+1);
	COFb[j].F=myfopen(COFb[j].N,"w");
	fprintf(COFb[j].F,"%10s%10s%12s%10s%10s\n","#Sim #","frame #","distance","O Resnum","O Atomnum");
	/* closest O info for the glycan */
	COFg[j].N=(char*)calloc(prefl+strlen("_Closest_O_g_i.dat")+1,sizeof(char));
	sprintf(COFg[j].N,"%s_Closest_O_g_%d.dat",PREF,j+1);
	COFg[j].F=myfopen(COFg[j].N,"w");
	fprintf(COFg[j].F,"%10s%10s%12s%10s%10s\n","#Sim #","frame #","distance","O Resnum","O Atomnum");
	}

ttot=0;
ICF.N=(char*)calloc(strlen(MDCRDLOC)+strlen(MDCRDSUF)+3,sizeof(char));
PF.N =(char*)calloc(strlen(PARMLOC)+strlen(PARMSUF)+3,sizeof(char));
bbtot[0]=bbtot[1]=bbtot[2]=bbtot[3]=0;
for(i=1;i<=NSIM;i++) /* note!!  not starting at zero!! */
	{
/* Find and read in the parm7 and mdcrd files for a given runset. */
	/** Load the topology file */
	PF.N=strdup("../../input/Solvated.parm7");
	sprintf(PF.N,"%s%d%s",PARMLOC,i,PARMSUF); /**< open the new trajectory file */
	A=load_amber_prmtop(PF); 
	/** Open the input trajcrd file */
	sprintf(ICF.N,"%s%d%s",MDCRDLOC,i,MDCRDSUF); /**< open the new trajectory file */
	ICF.F=myfopen(ICF.N,"r");
	tsi=0;
	test=fgetc(ICF.F);
	/* Initialize some stuff */
	frames[i-1]=0;
	nBr[i-1][0]=nBr[i-1][1]=nBr[i-1][2]=nBr[i-1][3]=0;
	n4W[i-1][0]=n4W[i-1][1]=n4W[i-1][2]=n4W[i-1][3]=0;
	n4W_noB[i-1][0]=n4W_noB[i-1][1]=n4W_noB[i-1][2]=n4W_noB[i-1][3]=0;
	nBr_no4[i-1][0]=nBr_no4[i-1][1]=nBr_no4[i-1][2]=nBr_no4[i-1][3]=0;
	/* find the moli's for the H's and O's */
	for(m=0;m<A.nm;m++)
		{ 
		for(r=0;r<A.m[m][0].nr;r++)
			{
			switch(A.m[m][0].r[r].n)
				{
				case 4: 
				case 5:
				case 6:
				case 7:
					j=A.m[m][0].r[r].n-4;
					for(a=0;a<A.m[m][0].r[r].na;a++)
						{
						if(strcmp("H",A.m[m][0].r[r].a[a].N)==0){
							HBSb[j].H=A.m[m][0].r[r].a[a].moli;
							Hb[j]=&A.m[m][0].r[r].a[a];
							}
						if(strcmp("N",A.m[m][0].r[r].a[a].N)==0){
							HBSb[j].D=A.m[m][0].r[r].a[a].moli;
							Nb[j]=&A.m[m][0].r[r].a[a];
							}
						if(strcmp("O",A.m[m][0].r[r].a[a].N)==0){
							Ob[j]=&A.m[m][0].r[r].a[a];
							}
						if(strcmp("OG1",A.m[m][0].r[r].a[a].N)==0){
							Og[j]=&A.m[m][0].r[r].a[a];
							}
						}
					break;
				case 12:
				case 13:
				case 14:
				case 15:
					j=A.m[m][0].r[r].n-12;
					for(a=0;a<A.m[m][0].r[r].na;a++)
						{
						if(strcmp("H2N",A.m[m][0].r[r].a[a].N)==0) 
							{
							HBSg[j].H=A.m[m][0].r[r].a[a].moli;
							Hg[j]=&A.m[m][0].r[r].a[a];
							}
						if(strcmp("N2",A.m[m][0].r[r].a[a].N)==0) 
							{
							HBSg[j].D=A.m[m][0].r[r].a[a].moli;
							Ng[j]=&A.m[m][0].r[r].a[a];
							}
						}
					break;
				default:
					break;
				}
			}
		}
	while(test != EOF){
		ungetc(test,ICF.F);
		tsi++;
		/** Load the first/next frame in the coordinate file */
		add_trajcrds_to_prmtop_assembly(ICF,&A,'c',0);
		ttot++;
		/* note any H2N or THR H that are near a wall for wrap-checking */
		/* get box info */
		b=A.nBOX-1;
		/* check each atom for possibly needing wrapped information */
			/* within 6 A of a wall */
			/* outside the box entirely */
		if(b<0) mywhine("No box information found.");
		frames[i-1]++;

		/* Print coords, minus water, out to a file */
		xfi=0;
		for(ai=0;ai<NATOMS;ai++) 
			{
			fprintf(Traj.F,"%8.3f",A.a[ai][0].xa[0].i);
			xfi++;
			if((xfi%10)==0) fprintf(Traj.F,"\n");
			fprintf(Traj.F,"%8.3f",A.a[ai][0].xa[0].j);
			xfi++;
			if((xfi%10)==0) fprintf(Traj.F,"\n");
			fprintf(Traj.F,"%8.3f",A.a[ai][0].xa[0].k);
			xfi++;
			if((xfi%10)==0) fprintf(Traj.F,"\n");
			}
		xfi++;
		if((xfi%10)!=0) fprintf(Traj.F,"\n");
		fflush(Traj.F);
		/* check for a 4-way sitation */
		Is4Way[0]=Is4Way[1]=Is4Way[2]=Is4Way[3]=0;
		IsBridge[0]=IsBridge[1]=IsBridge[2]=IsBridge[3]=0;
		for(j=0;j<4;j++) 
			{ 
			OO=get_magnitude(coord_to_vec(subtract_coord(Ob[j][0].xa[0],Og[j][0].xa[0])));
			if(OO>4.0) Is4Way[j]=1;
			if(j==3)
				{
				HH=get_magnitude(coord_to_vec(subtract_coord(Hb[j][0].xa[0],Hg[j][0].xa[0])));
				if(HH>5.0) Is4Way[j]=1;
				}
			if(Is4Way[j]==0)
				{
				/* Increment 4-Way counter */
				n4W[i-1][j]++;
				/* Print coords to a file */
				xfi=0;
				for(ai=0;ai<NATOMS;ai++) 
					{
					fprintf(T4W[j].F,"%8.3f",A.a[ai][0].xa[0].i);
					xfi++;
					if((xfi%10)==0) fprintf(T4W[j].F,"\n");
					fprintf(T4W[j].F,"%8.3f",A.a[ai][0].xa[0].j);
					xfi++;
					if((xfi%10)==0) fprintf(T4W[j].F,"\n");
					fprintf(T4W[j].F,"%8.3f",A.a[ai][0].xa[0].k);
					xfi++;
					if((xfi%10)==0) fprintf(T4W[j].F,"\n");
					}
				xfi++;
				if((xfi%10)!=0) fprintf(T4W[j].F,"\n");
				fflush(T4W[j].F);
				}
			}

		/* get X,Y,Z min and max for the two H's that might be mediated */
		/* also see if any min or max value is outside the box */
		for(j=0;j<4;j++) 
			{ 
			iminHg[j].i=iminHg[j].j=iminHg[j].k=imaxHg[j].i=imaxHg[j].j=imaxHg[j].k=1;
			iminHb[j].i=iminHb[j].j=iminHb[j].k=imaxHb[j].i=imaxHb[j].j=imaxHb[j].k=1;
			/* NAc hydrogen */
			minHg[j].i=Hg[j][0].xa[0].i-CLOSE;
			minHg[j].j=Hg[j][0].xa[0].j-CLOSE;
			minHg[j].k=Hg[j][0].xa[0].k-CLOSE;
			maxHg[j].i=Hg[j][0].xa[0].i+CLOSE;
			maxHg[j].j=Hg[j][0].xa[0].j+CLOSE;
			maxHg[j].k=Hg[j][0].xa[0].k+CLOSE;
			/* set integers to make the loop over all O's a little easier to read */
			if (minHg[j].i < 0.0) iminHg[j].i=0; /* set true, true=0 */
			if (minHg[j].j < 0.0) iminHg[j].j=0;
			if (minHg[j].k < 0.0) iminHg[j].k=0;
			if (maxHg[j].i > A.BOX[b].C[0].D[0]) imaxHg[j].i=0;
			if (maxHg[j].j > A.BOX[b].C[0].D[1]) imaxHg[j].j=0;
			if (maxHg[j].k > A.BOX[b].C[0].D[2]) imaxHg[j].k=0;
			/* test for sanity */
			if ((iminHg[j].i==0)&&(imaxHg[j].i==0)) mywhine("Hg i outside box on both sides");
			if ((iminHg[j].j==0)&&(imaxHg[j].j==0)) mywhine("Hg j outside box on both sides");
			if ((iminHg[j].k==0)&&(imaxHg[j].k==0)) mywhine("Hg k outside box on both sides");
			/* THR hydrogen */
			minHb[j].i=Hb[j][0].xa[0].i-CLOSE;
			minHb[j].j=Hb[j][0].xa[0].j-CLOSE;
			minHb[j].k=Hb[j][0].xa[0].k-CLOSE;
			maxHb[j].i=Hb[j][0].xa[0].i+CLOSE;
			maxHb[j].j=Hb[j][0].xa[0].j+CLOSE;
			maxHb[j].k=Hb[j][0].xa[0].k+CLOSE;
			if (minHb[j].i < 0.0) iminHb[j].i=0;
			if (minHb[j].j < 0.0) iminHb[j].j=0;
			if (minHb[j].k < 0.0) iminHb[j].k=0;
			if (maxHb[j].i > A.BOX[b].C[0].D[0]) imaxHb[j].i=0;
			if (maxHb[j].j > A.BOX[b].C[0].D[1]) imaxHb[j].j=0;
			if (maxHb[j].k > A.BOX[b].C[0].D[2]) imaxHb[j].k=0;
			/* test for sanity */
			if ((iminHb[j].i==0)&&(imaxHb[j].i==0)) mywhine("Hb i outside box on both sides");
			if ((iminHb[j].j==0)&&(imaxHb[j].j==0)) mywhine("Hb j outside box on both sides");
			if ((iminHb[j].k==0)&&(imaxHb[j].k==0)) mywhine("Hb k outside box on both sides");
			}
		/* Search for water O's that are within H-Bonding distance */
		closestOdb[0]=closestOdb[1]=closestOdb[2]=closestOdb[3]=CLOSE;
		closestOdg[0]=closestOdg[1]=closestOdg[2]=closestOdg[3]=CLOSE;
		OWg[0]=OWg[1]=OWg[2]=OWg[3]=NULL;
		OWb[0]=OWb[1]=OWb[2]=OWb[3]=NULL;
		for(m=0;m<A.nm;m++)
			{ 
			if(A.m[m][0].nr!=1) continue; 
			if(strcmp("WAT",A.m[m][0].r[0].N)!=0) continue;
			if(A.m[m][0].r[0].na!=3) mywhine("A water doesn't contain three atoms!");
			resnum=A.m[m][0].r[0].n;
			/* clear coordinates */
			Ocb.i=Ocb.j=Ocb.k=0.0;
			Ocg.i=Ocg.j=Ocg.k=0.0;
			Ocurr=NULL;
			rcurr=&A.m[m][0].r[0];
			/* get coordinates for the O in this water */
			for(a=0;a<3;a++) if(strcmp("O",A.m[m][0].r[0].a[a].N)==0) Ocurr=&A.m[m][0].r[0].a[a];
			/* check coords for sanity */
			if(Ocurr==NULL) mywhine("atom not found for Ocurr.");
			if((Ocurr[0].xa[0].i==0)&&(Ocurr[0].xa[0].j==0)&&(Ocurr[0].xa[0].k==0)) mywhine("Coords not found for Ocurr.");
			for(j=0;j<4;j++) /* For each glycan/threonine pair: */
				{ 
				Ocb=Ocg=Ocurr[0].xa[0];
				/* set effective, wrapped coordinates for the oxygen */
				if((iminHg[j].i==0)&&(Ocg.i>maxHg[j].i)) Ocg.i -= A.BOX[b].C[0].D[0];
				if((iminHg[j].j==0)&&(Ocg.j>maxHg[j].j)) Ocg.j -= A.BOX[b].C[0].D[1];
				if((iminHg[j].k==0)&&(Ocg.k>maxHg[j].k)) Ocg.k -= A.BOX[b].C[0].D[2];
				if((iminHb[j].i==0)&&(Ocb.i>maxHb[j].i)) Ocb.i -= A.BOX[b].C[0].D[0];
				if((iminHb[j].j==0)&&(Ocb.j>maxHb[j].j)) Ocb.j -= A.BOX[b].C[0].D[1];
				if((iminHb[j].k==0)&&(Ocb.k>maxHb[j].k)) Ocb.k -= A.BOX[b].C[0].D[2];
				if((imaxHg[j].i==0)&&(Ocg.i<minHg[j].i)) Ocg.i += A.BOX[b].C[0].D[0];
				if((imaxHg[j].j==0)&&(Ocg.j<minHg[j].j)) Ocg.j += A.BOX[b].C[0].D[1];
				if((imaxHg[j].k==0)&&(Ocg.k<minHg[j].k)) Ocg.k += A.BOX[b].C[0].D[2];
				if((imaxHb[j].i==0)&&(Ocb.i<minHb[j].i)) Ocb.i += A.BOX[b].C[0].D[0];
				if((imaxHb[j].j==0)&&(Ocb.j<minHb[j].j)) Ocb.j += A.BOX[b].C[0].D[1];
				if((imaxHb[j].k==0)&&(Ocb.k<minHb[j].k)) Ocb.k += A.BOX[b].C[0].D[2];
//printf("maxHg[%d].i,j,k = %f %f %f \n",j,maxHg[j].i,maxHg[j].j,maxHg[j].k);
//printf("Ocg.i,j,k = %f %f %f \n",Ocg.i,Ocg.j,Ocg.k);
//printf("maxHb[%d].i,j,k = %f %f %f \n",j,maxHb[j].i,maxHb[j].j,maxHb[j].k);
//printf("Ocb.i,j,k = %f %f %f \n",Ocb.i,Ocb.j,Ocb.k);
				/* check if the oxygen is near one of our target atoms */
				/* initialize the information container */
				HBSg[j].good=HBSb[j].good='n';
				HBSg[j].d=HBSb[j].d=CLOSE;
				HBSg[j].a=HBSb[j].a=-1.0;
				/* The glycan */
				OWgcheck[j]=0;
				if((Ocg.i>maxHg[j].i)||(Ocg.i<minHg[j].i)) OWgcheck[j]++;
				if((OWgcheck[j]==0)&&((Ocg.j>maxHg[j].j)||(Ocg.j<minHg[j].j))) OWgcheck[j]++;
				if((OWgcheck[j]==0)&&((Ocg.k>maxHg[j].k)||(Ocg.k<minHg[j].k))) OWgcheck[j]++;
//printf("OWgcheck[%d] is %d\n",j,OWgcheck[j]);
				if(OWgcheck[j]==0) /* if there is any chance of this oxygen being close enough */
					{
//printf("===========================================================\n");
//printf("===========================================================\n");
					/* check and save minimum distance info */
					HBSg[j].d=get_magnitude(coord_to_vec(subtract_coord(Ocg,Hg[j][0].xa[0])));
					if(HBSg[j].d==0) mywhine("soemthing went horribly wrong:  HBSg[j].d==0.");
					if(HBSg[j].d<closestOdg[j]) 
						{ 
						OWg[j]=Ocurr;
						closestOdg[j]=HBSg[j].d; 
						}
					/* see if this is a hydrogen bond */
					HBSg[j].a=get_angle_ABC_points(Ng[j][0].xa[0],Hg[j][0].xa[0],Ocg);
//printf("\tHBSg[%d].d=%f  HBSg[j].a=%f  closestOdg[j]=%f\n",j,HBSg[j].d,HBSg[j].a,closestOdg[j]);
					if((HBSg[j].d<=LENGTH)&&(HBSg[j].a>=ANGLE)) HBSg[j].good='y';
//printf("===========================================================\n");
//printf("===========================================================\n");
					}
				/* the backbone */
				OWbcheck[j]=0;
				if((Ocb.i>maxHb[j].i)||(Ocb.i<minHb[j].i)) OWbcheck[j]++;
				if((OWbcheck[j]==0)&&((Ocb.j>maxHb[j].j)||(Ocb.j<minHb[j].j))) OWbcheck[j]++;
				if((OWbcheck[j]==0)&&((Ocb.k>maxHb[j].k)||(Ocb.k<minHb[j].k))) OWbcheck[j]++;
//printf("OWbcheck[%d] is %d\n",j,OWbcheck[j]);
				if(OWbcheck[j]==0) /* if there is any chance of this oxygen being close enough */
					{
//printf("===========================================================\n");
//printf("===========================================================\n");
					/* check and save minimum distance info */
					HBSb[j].d=get_magnitude(coord_to_vec(subtract_coord(Ocb,Hb[j][0].xa[0])));
					if(HBSb[j].d==0) mywhine("something went horribly wrong:  HBSb[j].d==0.");
					if(HBSb[j].d<closestOdb[j]) 
						{ 
						OWb[j]=Ocurr;
						closestOdb[j]=HBSb[j].d; 
						}
					/* see if this is a hydrogen bond */
					HBSb[j].a=get_angle_ABC_points(Nb[j][0].xa[0],Hb[j][0].xa[0],Ocb);
//printf("\tHBSb[%d].d=%f  HBSb[j].a=%f  closestOdb[j]=%f\n",j,HBSb[j].d,HBSb[j].a,closestOdb[j]);
					if((HBSb[j].d<=LENGTH)&&(HBSb[j].a>=ANGLE)) HBSb[j].good='y';
//printf("===========================================================\n");
//printf("===========================================================\n");
					}
				if((OWbcheck[j]==0)&&(OWgcheck[j]!=0)) /* get distance/angle for other that is far */
					{
					if(HBSg[j].good=='y') mywhine("HBSg should not be good here");
					HBSg[j].d=get_magnitude(coord_to_vec(subtract_coord(Ocg,Hg[j][0].xa[0])));
					HBSg[j].a=get_angle_ABC_points(Ng[j][0].xa[0],Hg[j][0].xa[0],Ocg);
					}
				if((OWgcheck[j]==0)&&(OWbcheck[j]!=0)) /* get distance/angle for other that is far */
					{
					if(HBSb[j].good=='y') mywhine("HBSb should not be good here");
					HBSb[j].d=get_magnitude(coord_to_vec(subtract_coord(Ocb,Hb[j][0].xa[0])));
					HBSb[j].a=get_angle_ABC_points(Nb[j][0].xa[0],Hb[j][0].xa[0],Ocb);
					}
				/* is this bridging? */
				if((HBSb[j].good=='y')&&(HBSg[j].good=='y'))/**<  Yes, this is bridging */
					{
					IsBridge[j]++; /* say we found a bridge, but increment to check for multiple later */
					bbtot[j]++; /* increment total number of bridging bonds found */
					nBr[i-1][j]++;
					/** Print info to bridged bonds info file BOF[4], Files:  Bridge_bonds_i.dat */
					fprintf(BOF[j].F,"%10d%10d%10d%12.4f%12.4f%12.4f%12.4f%10d%10d\n",\
						bbtot[j],i,tsi,HBSb[j].d,HBSg[j].d,HBSb[j].a*180.0/PI,HBSg[j].a*180.0/PI,resnum,Ocurr[0].n);
					/** Print coords to the bridged bonds coordinate file TOF[4], Files:  Bridge_bonds_i.mdcrd 
						 But... only print glycan plus bridging water */
                              		xfi=0;
                                	for(ai=0;ai<NATOMS;ai++) 
                                        	{
                                        	fprintf(TOF[j].F,"%8.3f",A.a[ai][0].xa[0].i);
                                        	xfi++;
                                        	if((xfi%10)==0) fprintf(TOF[j].F,"\n");
                                        	fprintf(TOF[j].F,"%8.3f",A.a[ai][0].xa[0].j);
                                        	xfi++;
                                        	if((xfi%10)==0) fprintf(TOF[j].F,"\n");
                                        	fprintf(TOF[j].F,"%8.3f",A.a[ai][0].xa[0].k);
                                        	xfi++;
                                        	if((xfi%10)==0) fprintf(TOF[j].F,"\n");
                                        	}
					WAT[0]=WAT[1]=WAT[2]=NULL;
					WAT[0]=&Ocurr[0];
					for(ai=0;ai<3;ai++)
						{
						if((strcmp("O",rcurr[0].a[ai].N)==0)&&(WAT[ai][0].xa[0].i!=rcurr[0].a[ai].xa[0].i))
							{
							mywhine("The oxygen coords are not the same!");
							}
						if(strcmp("H1",rcurr[0].a[ai].N)==0) WAT[1]=&rcurr[0].a[ai];
						if(strcmp("H2",rcurr[0].a[ai].N)==0) WAT[2]=&rcurr[0].a[ai];
						}
					if(WAT[0]==NULL) mywhine("WAT[0] is NULL!");
					if(WAT[1]==NULL) mywhine("WAT[1] is NULL!");
					if(WAT[2]==NULL) mywhine("WAT[2] is NULL!");
					/* print the three water coordinates */
                                	for(ai=0;ai<3;ai++) 
                                       		{
						fprintf(TOF[j].F,"%8.3f",WAT[ai][0].xa[0].i);
                                       		xfi++;
                                       		if((xfi%10)==0) fprintf(TOF[j].F,"\n");
						fprintf(TOF[j].F,"%8.3f",WAT[ai][0].xa[0].j);
                                       		xfi++;
                                       		if((xfi%10)==0) fprintf(TOF[j].F,"\n");
						fprintf(TOF[j].F,"%8.3f",WAT[ai][0].xa[0].k); 
                                       		xfi++;
                                        	if((xfi%10)==0) fprintf(TOF[j].F,"\n");
						}
                                        	if((xfi%10)!=0) fprintf(TOF[j].F,"\n");
					/* Don't print box info normally.  Uncomment if desired. 
					fprintf(TOF[j].F,"%8.3f%8.3f%8.3f\n",A.BOX[b].C[0].D[0],A.BOX[b].C[0].D[1],A.BOX[b].C[0].D[2]); */
					if(Is4Way[j]!=0) /* if there is NOT a 4-way interaction, print to that file */
						{
						/* increment the counter */
						nBr_no4[i-1][j]++;
                              			xfi=0;
                                		for(ai=0;ai<NATOMS;ai++) 
                                        		{
                                        		fprintf(TBr_no4[j].F,"%8.3f",A.a[ai][0].xa[0].i);
                                        		xfi++;
                                        		if((xfi%10)==0) fprintf(TBr_no4[j].F,"\n");
                                        		fprintf(TBr_no4[j].F,"%8.3f",A.a[ai][0].xa[0].j);
                                        		xfi++;
                                        		if((xfi%10)==0) fprintf(TBr_no4[j].F,"\n");
                                        		fprintf(TBr_no4[j].F,"%8.3f",A.a[ai][0].xa[0].k);
                                        		xfi++;
                                        		if((xfi%10)==0) fprintf(TBr_no4[j].F,"\n");
                                        		}
						/* print the three water coordinates */
                                		for(ai=0;ai<3;ai++) 
                                        		{
							fprintf(TBr_no4[j].F,"%8.3f",WAT[ai][0].xa[0].i);
                                       			xfi++;
                                       			if((xfi%10)==0) fprintf(TBr_no4[j].F,"\n");
							fprintf(TBr_no4[j].F,"%8.3f",WAT[ai][0].xa[0].j);
                                       			xfi++;
                                       			if((xfi%10)==0) fprintf(TBr_no4[j].F,"\n");
							fprintf(TBr_no4[j].F,"%8.3f",WAT[ai][0].xa[0].k); 
                                       			xfi++;
                                       			if((xfi%10)==0) fprintf(TBr_no4[j].F,"\n");
							}
                                       			if((xfi%10)!=0) fprintf(TBr_no4[j].F,"\n");
						/* Don't print box info normally.  Uncomment if desired. 
						fprintf(TBr_no4[j].F,"%8.3f%8.3f%8.3f\n",A.BOX[b].C[0].D[0],A.BOX[b].C[0].D[1],A.BOX[b].C[0].D[2]); */
						}
					}
				/** print out info for Hbonds, bridged and not */
				if(HBSb[j].good=='y') /* backbone */
					{
					fprintf(HOFb[j].F,"%10d%10d%12.4e%12.4e%12.4e%12.4e%10d%10d\n",\
						i,tsi,HBSb[j].d,HBSg[j].d,HBSb[j].a*180.0/PI,HBSg[j].a*180.0/PI,resnum,Ocurr[0].n);
					}
				if(HBSg[j].good=='y') /* glycan */
					{
					fprintf(HOFg[j].F,"%10d%10d%12.4e%12.4e%12.4e%12.4e%10d%10d\n",\
						i,tsi,HBSb[j].d,HBSg[j].d,HBSb[j].a*180.0/PI,HBSg[j].a*180.0/PI,resnum,Ocurr[0].n);
					}
				} /* close per residue set loop */
			} /* close per molecule loop */
		for(j=0;j<4;j++) /* For each glycan/threonine pair: */
			{ 
			if(IsBridge[j]>1) printf("Found multiple waters bridging for residue %d, simulation %d, frame %d!\n",j,i,tsi);
			if((IsBridge[j]==0)&&(Is4Way[j]==0)) /* if there is a 4-way interaction, but NOT a bridge, print to that file */
				{
				/* increment the counter */
				n4W_noB[i-1][j]++;
				xfi=0;
				for(ai=0;ai<NATOMS;ai++) 
					{
					fprintf(T4W_noB[j].F,"%8.3f",A.a[ai][0].xa[0].i);
					xfi++;
					if((xfi%10)==0) fprintf(T4W_noB[j].F,"\n");
					fprintf(T4W_noB[j].F,"%8.3f",A.a[ai][0].xa[0].j);
					xfi++;
					if((xfi%10)==0) fprintf(T4W_noB[j].F,"\n");
					fprintf(T4W_noB[j].F,"%8.3f",A.a[ai][0].xa[0].k);
					xfi++;
					if((xfi%10)==0) fprintf(T4W_noB[j].F,"\n");
					}
				xfi++;
				if((xfi%10)!=0) fprintf(T4W_noB[j].F,"\n");
				/* Don't print box info normally.  Uncomment if desired. 
				fprintf(T4W_noB[j].F,"%8.3f%8.3f%8.3f\n",A.BOX[b].C[0].D[0],A.BOX[b].C[0].D[1],A.BOX[b].C[0].D[2]); */
				}
			/** print info about closest O info for both */
			if(OWg[j]==NULL)
				{
				fprintf(COFg[j].F,"%10d%10d%12s%10s%10s\n",i,tsi,"M","M","M");
				}
			else
				{
				resnum=A.m[OWg[j][0].moli.m][0].r[OWg[j][0].moli.r].n;
				fprintf(COFg[j].F,"%10d%10d%12.4e%10d%10d\n",i,tsi,closestOdg[j],resnum,OWg[j][0].n);
				}
			if(OWb[j]==NULL)
				{
				fprintf(COFb[j].F,"%10d%10d%12s%10s%10s\n",i,tsi,"M","M","M");
				}
			else
				{
				resnum=A.m[OWb[j][0].moli.m][0].r[OWb[j][0].moli.r].n;
				fprintf(COFb[j].F,"%10d%10d%12.4e%10d%10d\n",i,tsi,closestOdb[j],resnum,OWb[j][0].n);
				}
			}
//printf("tsi is %d j is %d \n",tsi,j);
		/** Now, reset everything for the next read */
		for(ai=0;ai<A.na;ai++)
			{
			free(A.a[ai][0].xa);
			A.a[ai][0].xa=NULL;
			A.a[ai][0].nalt=0;
			A.a[ai][0].t=0; /* set this back to zero */
			}	
//printf("just deallocated the coords\n");
		if(A.nBOX>1)
			{
			for(ai=1;ai<A.nBOX;ai++) deallocateBoxinfo(&A.BOX[ai]);
			//free(A.BOX);
			A.nBOX=1;
			}
		test=fgetc(ICF.F);
		}
//printf("just deallocated the box\n");
	fclose(ICF.F);
	//fclose(PF.F);
//printf("about to deallocate the assembly's void pointer, i=%d \n",i);
	AP=&(A.VP[0]);
	deallocateAmberPrmtop(AP);
	free(A.VP);
	A.VP=NULL;
	A.nVP=0;
//printf("about to deallocate the assembly, i=%d \n",i);
	//deallocateFullAssembly(&A);
	for(j=0;j<4;j++)
		{
		fprintf(BOF[j].F,"\n");
		fprintf(COFg[j].F,"\n");
		fprintf(COFb[j].F,"\n");
		fprintf(HOFg[j].F,"\n");
		fprintf(HOFb[j].F,"\n");
		}
	}

fprintf(SUM.F,"# For columns with two numbers, first is total number, second is fraction \n#\n");
fprintf(SUM.F,"#%12s %12s %12s %20s %20s %20s %20s\n","Simulation","Location","Frames","4-Way","Bridged","4-Way-no-bridge","Bridge-no-4-Way");
i=j=0;
for(j=0;j<4;j++)
	{
	fprintf(SUM.F," %12d %12d %12d %10d%10.4f %10d%10.4f %10d%10.4f %10d%10.4f\n",1,j+1,frames[0],\
		n4W[0][j],(float)n4W[0][j]/(float)frames[0],\
		nBr[0][j],(float)nBr[0][j]/(float)frames[0],\
		n4W_noB[0][j],(float)n4W_noB[0][j]/(float)frames[0],\
		nBr_no4[0][j],(float)nBr_no4[0][j]/(float)frames[0]);
	}
for(i=1;i<NSIM;i++)
	{
	for(j=0;j<4;j++)
		{
		fprintf(SUM.F," %12d %12d %12d %10d%10.4f %10d%10.4f %10d%10.4f %10d%10.4f\n",i+1,j+1,frames[i],
			n4W[i][j],(float)n4W[i][j]/(float)frames[i],\
			nBr[i][j],(float)nBr[i][j]/(float)frames[i],\
			n4W_noB[i][j],(float)n4W_noB[i][j]/(float)frames[i],\
			nBr_no4[i][j],(float)nBr_no4[i][j]/(float)frames[i]);
		n4W[0][j]+=n4W[i][j];
		nBr[0][j]+=nBr[i][j];
		n4W_noB[0][j]+=n4W_noB[i][j];
		nBr_no4[0][j]+=nBr_no4[i][j];
		}
	frames[0]+=frames[i];
	}
fprintf(SUM.F,"# Summaries Across All Simulations\n\n");
fprintf(SUM.F,"#%12s %12s %20s %20s %20s %20s\n","Location","Frames","4-Way","Bridged","4-Way-no-bridge","Bridge-no-4-Way");
for(j=0;j<4;j++)
	{
	fprintf(SUM.F," %12d %12d %10d%10.4f %10d%10.4f %10d%10.4f %10d%10.4f\n",j+1,frames[0],
		n4W[0][j],(float)n4W[0][j]/(float)frames[0],\
		nBr[0][j],(float)nBr[0][j]/(float)frames[0],\
		n4W_noB[0][j],(float)n4W_noB[0][j]/(float)frames[0],\
		nBr_no4[0][j],(float)nBr_no4[0][j]/(float)frames[0]);
	}


return 0;
}
