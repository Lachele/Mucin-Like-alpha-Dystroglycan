#include <glylib.h>
#include "Get_SDM_bins_general.c"

/* USAGE 
       CheckSDMf InputFile  
		# Assumes the file just contains a column of numbers
       CheckSDMf InputFile ptraj
		# if "ptraj" is added, assumes the file contains ptraj-like output
		# That is, the first line is a comment (less than 250 chars) and the other lines
		# contain an index followed by a number to be used
*/

int main (int argc, char *argv[]) 
{
int N=0,i=0,j=0;
SDMInfo SDI;
FILE *IF,*OF1,*OF2;
double *DATA,tmpd=0,mind=0,maxd=0,avgd=0;
int filechar=0;
char tmps[300];

/* Require "program input_file array_length" */
if(argc<2) mywhine("not enough arguments: program input_file ");

/* open the input file and read parts into an array */
IF=myfopen(argv[1],"r");
N=cscan_file(IF,'\n');
rewind(IF);
DATA=(double*)calloc(N,sizeof(double));
if(argv[2]==NULL){
	fscanf(IF,"%lf",&DATA[0]);
	maxd=DATA[0];
	for(i=1;i<N;i++)
		{
		fscanf(IF,"%lf",&DATA[i]);
		if(DATA[i]>maxd) maxd=DATA[i];
		}
	}
else if(strcmp(argv[2],"ptraj")!=0){mywhine("Argument two must be ptraj of empty.");}
else 
	{
	N--; // so... the array is one element too long now... oh, horror....
	filechar=fgetc(IF);
	if(filechar!='#'){ ungetc(filechar,IF); }
	else {fgets(tmps,250,IF);}
	fscanf(IF,"%lf %lf",&tmpd,&DATA[0]);
	maxd=DATA[0];
	for(i=1;i<N;i++)
		{
		fscanf(IF,"%lf %lf",&tmpd,&DATA[i]);
		if(DATA[i]>maxd) maxd=DATA[i];
		}
	}

/* Send the array to the new function */
SDI=getSDMInfo(N,DATA);

OF1=myfopen("SDMPlotInfo.txt","w");
OF2=myfopen("SDMDetails.txt","w");

/* Print header info to both output files*/
fprintf(OF1,"# Printing SDM info for the following input:\n#      ");
for(i=0;i<3;i++) fprintf(OF1,"%s ",argv[i]);
fprintf(OF1,"\n# The overall mean and fluctuations for the %d values are: %g +/- %g\n",N,SDI.Mean,SDI.SDM[0]);
fprintf(OF2,"# Printing SDM info for the following input:\n#      ");
for(i=0;i<3;i++) fprintf(OF2,"%s ",argv[i]);
fprintf(OF2,"\n# The overall mean and fluctuations are: %g +/- %g\n",SDI.Mean,SDI.SDM[0]);
/* Print details to the details file */
fprintf(OF2,"\n#\n# Here are the sdm's calculated per the indicated number of points:\n");
fprintf(OF2,"# NPts    sdm1           sdm2           |sdm-diff|        slope1         slope2         \n");
tmpd=mind=1000*fabs(maxd);
for(i=0;i<SDI.nFit;i++) {
	tmpd=fabs(SDI.sdm1[i]-SDI.sdm2[i]);
	if(mind>tmpd)
		{
		mind=tmpd;
		avgd=0.5*(SDI.sdm1[i]+SDI.sdm2[i]);
//printf("avgd is %f and mind is %f\n",avgd,mind);
		}
	fprintf(OF2,"%10d%15g%15g%15g%15g%15g\n",\
		SDI.Fit[i],SDI.sdm1[i],SDI.sdm2[i],tmpd,SDI.slope1[i],SDI.slope2[i]); 
	}
fprintf(OF2,"\n#\n#BestSDM %15f \n",avgd);
fprintf(OF2,"\n#\n# Here are the bin sizes used:\n");
for(i=0;i<SDI.n;i++)
	{
	fprintf(OF2,"# %d :",i+1);
	for(j=0;j<SDI.I[i];j++)
		{
		fprintf(OF2,"\t%d",SDI.BinSz[i][j]);
		}
	fprintf(OF2,"\n");
	}
/* Print plot info to the plot info files*/
fprintf(OF1,"#\n# Here are the SDM's over the bins:\n");
fprintf(OF1,"# SDI.I       ln(I)          SDI.SDM        ln(SDM)     \n");
fprintf(OF1,"# %8d%15g%15g%15g\n",SDI.I[0],log(SDI.I[0]),SDI.SDM[0],log(SDI.SDM[0]));
for(i=1;i<SDI.n;i++) fprintf(OF1,"%10d%15g%15g%15g\n",SDI.I[i],log(SDI.I[i]),SDI.SDM[i]/sqrt(i+1),log(SDI.SDM[i]));

return 0;
}
