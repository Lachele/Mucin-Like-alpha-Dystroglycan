#!/usr/bin/perl
#reads ptraj/vmd output files for torsions selects data from the second column, computes jcouplings and standard deviation
# Developed by Matthew B. Tessier, 2011, CCRC, UGA
#
# And totally changed by Lachele on 20121226. -- dropping all but the ones I use...
#
# Last updated 2011-04-15 to include #s 8-11
# Contributions made by A. Yongye, Juan Carlos Munoz Garcia (juan.munioz@iiq.csic.es)
# Use by permission only
# Adapted from scripts by A. Yongye, 2008
# Usage ./J-Couplings.pl <input file> <J-coupling method>

use strict;
use Math::Trig;
my $pi = 22/7;
my $i=0;
my @ary; # Array with torsion values
my $eqn; # Karplus equation selection
my $pos_gauche=0;
my $neg_gauche=0;
my $trans=0;

my @karplus_table=(
"HN-N-Ca-Ha, Consensus from J. Schmidt, J Mag Res, 2007, 186, pp 34-50 (BLF)",#12
"HN-N-Ca-Ha for THR, ibid",#13
"Ha-Ca-Cb-Hb, Consensus, ibid",#14
"Ha-Ca-Cb-Hb for THR, ibid", #15
"H2N-N2-C2-H2 for GalNAc, JPhysChemB, 2011, 115,11215", #16
"HN-N-Ca-Ha, from David Live, so ask him (BLF)"#17
);

#### Subroutines ##################################################################################################
# The Karplus Equation subroutine
sub karplus {
# $selection ($_[0]) is the Karplus Equation selection number, $torsion ($_[1]) is the torsion value to use in the Karplus Equation
  my ($selection, $torsion) = @_;
  my $jcoup1;

######### J-Coupling Equation Definitions ###################################################
#############################################################################################
##### J-Couplings (HN-N-Ca-Ha) (Consensus, J. Schmidt, J Mag Res, 2007, 186, pp 34-50 (BLF)) #########################################
if($selection==12){ # 
        $jcoup1 = 8.09*(cos(($pi*$torsion)/180)**2) - 1.00*(cos(($pi*$torsion)/180)) + 1.01;
}
##### J-Couplings (HN-N-Ca-Ha) (THR only, J. Schmidt, J Mag Res, 2007, 186, pp 34-50 (BLF)) #########################################
elsif($selection==13){ # 
        $jcoup1 = 8.09*(cos(($pi*$torsion)/180)**2) - 1.00*(cos(($pi*$torsion)/180)) + 0.78;
}
##### J-Couplings (Ha-Ca-Cb-Hb) (Consensus, J. Schmidt, J Mag Res, 2007, 186, pp 34-50 (BLF)) #########################################
elsif($selection==14){ # 
        $jcoup1 = 8.77*(cos(($pi*$torsion)/180)**2) - 1.18*(cos(($pi*$torsion)/180)) + 1.46;
}
##### J-Couplings (Ha-Ca-Cb-Hb) (THR only, J. Schmidt, J Mag Res, 2007, 186, pp 34-50 (BLF)) #########################################
elsif($selection==15){ # 
        $jcoup1 = 8.77*(cos(($pi*$torsion)/180)**2) - 1.18*(cos(($pi*$torsion)/180)) + 0.07;
}
##### J-Couplings (H2N-N2-C2-H2) (GalNAc only, JPhysChemB, 2011, 115, 11215 (BLF)) #########################################
elsif($selection==16){ # 
        $jcoup1 = 9.60*(cos(($pi*$torsion)/180)**2) - 1.51*(cos(($pi*$torsion)/180)) + 0.99;
}
##### J-Couplings (H2N-N2-C2-H2) (GalNAc only, JPhysChemB, 2011, 115, 11215 (BLF)) #########################################
elsif($selection==17){ # 
        $jcoup1 = 6.51*(cos(($pi*$torsion)/180)**2) - 1.76*(cos(($pi*$torsion)/180)) + 1.60;
}
#elsif($selection==changeme){ # H-C-C-H from Haasnoot et al. Tetrahedron 1980, 36, pg 2783-2792
		# J = P(1)*cos(theta)**2 - P(2)*cos(theta) + P(3) + SUM(dX{P(4) + P(5) cos(Epsilon*theta+P(6)*|dX|)**2})
		# dXgroup=dXalphaSubstituent-P(7)*SUM(dXbetaSubstituent)
#		my $P1=13.24; my $P2=-0.91; my $P3=0; my $P4=0.53; my $P5=-2.41; my $P6=(($pi*15.5)/180); my $P7=0.19;
#                $jcoup1 = 13.24*(cos(($pi*$torsion)/180)**2) - 0.91*(cos(($pi*$torsion)/180)) + 1.32871 + 0.22654*(cos(($pi*$torsion)/180+1.457)**2) - 2.94984*(cos(18.972-($pi*$torsion)/180)**2) - 0.18557*(cos(1.1935+($pi*$torsion)/180)**2) - 3.133*(cos(20.15-($pi*$torsion)/180)**2);
#}

##### End of Two Proton J-Couplings (H-X-X-H) ##################################
else { # If no J-Coupling was selected
	die "\n\tInappropriate J-Coupling value selected.  Please select from the table above.\n";
}
################################################################################
return($jcoup1);
}

#########################################################################################################################
# Input file Checks
if (defined($ARGV[0]) == 1 | -e "@ARGV[0]") {
open(VAL,$ARGV[0]);
}
else {
	print "Please enter name of ptraj output file: ";
	$ARGV = <STDIN>;
	open(VAL,$ARGV);
}
# Karplus Equation to use
if (defined($ARGV[1]) == 1 ) {
	$eqn = $ARGV[1];
	#print "\nSelected Karplus Equation No. ".$eqn."\n\t".$karplus_table[$eqn]."\n\n";
}
else {
	die;
        #print "Please enter the number of the desired Karplus Equation (see table above):";
        #$ARGV = <STDIN>;
	#$eqn = $ARGV;
        #print "\nSelected Karplus Equation No. ".$eqn."\t".$karplus_table[$eqn]."\n\n";
}
$i = 0;
	while(<VAL>){
		next if /#/;
		my @tmp= split(' ',$_);
#		if($i==0){print "$tmp[1] is the first value\n";}
		$ary[$i]=$tmp[1];
#		print "$ary[$i]\n";
		$i++;
	}
#print "$#ary is the length of \$ary which should be ".($i - 1)."\n";
	close(VAL);
$i=0;

	while( $i <= $#ary){ # Reading through the torsion values
		if($ary[$i] < 0){ $ary[$i] = (360 + $ary[$i]); }
                                if(($ary[$i] >= 0)and($ary[$i] <= 120)){
					print &karplus($eqn,$ary[$i])."\n"; # Storing the J-values in an array for other uses
                                }
                                elsif(($ary[$i] > 120)and($ary[$i] <= 240)){
                                        print &karplus($eqn,$ary[$i])."\n";# Storing the J-values in an array for other uses

                                }
                                elsif(($ary[$i] > 240)and($ary[$i] <= 360)){
                                        print &karplus($eqn,$ary[$i])."\n"; # Storing the J-values in an array for other uses
                                }
		$i++;
	}


