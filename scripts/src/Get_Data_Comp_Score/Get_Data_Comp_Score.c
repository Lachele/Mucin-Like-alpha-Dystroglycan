#include <glylib.h>
/*

This is a very special-purpose thing.  It takes two sets of binned data that
	have been normalized by 1/sart(n) and:

	- multiplies each point, saving the output to a new file
	- adds up the products to make an overal score

The procedure is, essentially, an overlap integral a' la quantum mechanics.

The two files must be IDENTICAL except that the binned data columns don't 
	have to be in the same location.  The X, XY, XYZ, etc, *do* all have 
	to be the first 1, 2, 3, etc., columns.

The score (only *) is written to stdout.  The products for each point are in DataOut.
	If you want to keep up with this info, use a script.

	(*) Unless something goes wrong.

Usage:

	do_data_overlap File1 File2 Dimensions Col1 Col2 DataOut

where
	File1 and File2 contain the binned data
	Dimensions is the number of initial columns to copy over to DataOut
	Col1 and Col2 are the binned points of interest in File1 and File2
	DataOut is the file that will contain the product data

NOTE:   No line can be longer than 500 chars.  Need more? Rewrite it...
	
*/


int main(int argc, char *argv[])
{
int Dims=0,Col1=0,Col2=0,tmpc1,tmpc2,i;
fileset In1,In2,Out;
double x1,x2,val1,val2,prod,prod_sum=0;
char line[501];

if(argc<7) mywhine("Incorrect number of arguments.");

In1.N=strdup(argv[1]);
In1.F=myfopen(In1.N,"r");
In2.N=strdup(argv[2]);
In2.F=myfopen(In2.N,"r");
Out.N=strdup(argv[6]);
Out.F=myfopen(Out.N,"w");
fprintf(Out.F,"%11s\t%11s\t%20s\n","#   X","  Y","Product");

sscanf(argv[3],"%d",&Dims);
sscanf(argv[4],"%d",&Col1);
sscanf(argv[5],"%d",&Col2);

if(Col1<=Dims) mywhine("Col1 cannot be less than or equal to Dims");
if(Col2<=Dims) mywhine("Col2 cannot be less than or equal to Dims");

tmpc1=getc(In1.F);
while (tmpc1!=EOF)
	{
	if(tmpc1=='\n')
		{
		tmpc2=getc(In2.F);
		if(tmpc2!='\n') mywhine("file mismatch at starting newline character.");
		tmpc1=getc(In1.F);
		continue;
		}
	if(tmpc1!='#')
		{
		ungetc(tmpc1,In1.F);
		for(i=0;i<Dims;i++)
			{
			fscanf(In1.F,"%lf",&x1);
			fscanf(In2.F,"%lf",&x2);
			if(fabs(x1-x2)>0.0000000001) mywhine("Mismatch in colunms.");
			fprintf(Out.F,"%11.2f",x1);
			}
		for(i=Dims;i<Col1;i++) fscanf(In1.F,"%lf",&val1);
		for(i=Dims;i<Col2;i++) fscanf(In2.F,"%lf",&val2);
		prod=val1*val2;
		prod_sum+=prod;
		fprintf(Out.F,"%20.5e\n",prod);
		}
	if(fgets(line,500,In1.F)==NULL) mywhine("Problem completing a line for file 1.");
	if(fgets(line,500,In2.F)==NULL) mywhine("Problem completing a line for file 2.");
	tmpc1=getc(In1.F);
	}
printf("%20.5e\n",prod_sum);
return 0;
}
