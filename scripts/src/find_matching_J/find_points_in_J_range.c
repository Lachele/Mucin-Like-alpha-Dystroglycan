/* find_points_in_J_range.c
	begun on 2015-01-02 by BLFoley

	The purpose of this is to scan through the calculated 2D J-coupling
	values and extract into a separate file the Phi and Psi (and J) 
	for those whose J's fall into the specified range.

	Usage:  

		get_J_points Runs Set min max

		* Runs is the number of runs (32, 36 or 48)
		* Set is an integer 1-4, representing the THR site to consider.
		* min and max are the min and max J-values to consider.

	Call me from the 2D_J-Coupling directory.

*/

#include <glylib.h>

#define OUTPREF "Points_in_range_"
#define OUTSUFF ".txt"

int main(int argc, char *argv[])
{
int i,Set,Runs;
float min,max,actual,Phi,Psi;
fileset Ang,Jval,Out;

if(argc!=5) mywhine("wrong number of command-line arguments");
sscanf(argv[1],"%d",&Runs);
sscanf(argv[2],"%d",&Set);
sscanf(argv[3],"%f",&min);
sscanf(argv[4],"%f",&max);

Ang.N=(char*)calloc(5,sizeof(char));
Jval.N=(char*)calloc(10,sizeof(char));
Out.N=(char*)calloc(strlen(OUTPREF)+strlen(OUTSUFF)+2,sizeof(char));
sprintf(Out.N,"%s%d%s",OUTPREF,Set,OUTSUFF);
Out.F=myfopen(Out.N,"w");

for(i=1;i<=Runs;i++)
	{
	sprintf(Ang.N,"%d_%d",Set,i);
	sprintf(Jval.N,"JOUT_%d_%d",Set,i);
	Ang.F=myfopen(Ang.N,"r");
	Jval.F=myfopen(Jval.N,"r");
	while(fscanf(Ang.F,"%f %f",&Phi,&Psi)!=EOF)
		{
		if(fscanf(Jval.F,"%f",&actual)!=1) mywhine("Problem reading J file");
		if((actual>=min)&&(actual<max)) fprintf(Out.F,"%10.4f\t%10.4f\t%10.4f\n",Phi,Psi,actual);
		}
	fclose(Ang.F);
	fclose(Jval.F);
	}

return 0;
}
