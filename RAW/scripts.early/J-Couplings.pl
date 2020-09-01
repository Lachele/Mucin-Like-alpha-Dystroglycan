#!/usr/bin/perl
#reads ptraj/vmd output files for torsions selects data from the second column, computes jcouplings and standard deviation
# Developed by Matthew B. Tessier, 2011, CCRC, UGA
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
"C-O-C-H from Tvaroska, I. et al. Carbohydr Res 1989, 189, pp 359", # 0
"C-C-C-H from ???", #1
"C1-O5-C5-C6 from Bose et al. JACS 1998, 120, pg 11158-11173",#2
"H-C-C-H from Haasnoot et al. Tetrahedron 1980, 36, pg 2783-2792",#3
"H5-C5-C6-H6R (use omega: O5-C5-C6-O6 as input) from Stenutz, R., et al. J Org Chem, 2002, 67, pp 949",#4
"H5-C5-C6-H6S (use omega: O5-C5-C6-O6 as input) from Stenutz, R., et al. J Org Chem, 2002, 67, pp 949",#5
"H-C7-C8-H non-glycosidic from Haasnoot et al. Tetrahedron 1980, 36, pp 2783-2792",#6
"H-C7-C8-H glycosidic from Haasnoot et al. Tetrahedron 1980, 36, pp 2783-2792",#7
"H1-C-C-H2 for A-L-IdoA-2-OSO3",#8
"H2-C-C-H3 for A-L-IdoA-2-OSO3",#9
"H3-C-C-H4 for A-L-IdoA-2-OSO3",#10
"H4-C-C-H5 for A-L-IdoA-2-OSO3",#11
"HN-N-Ca-Ha, Consensus from J. Schmidt, J Mag Res, 2007, 186, pp 34-50 (BLF)",#12
"HN-N-Ca-Ha for THR, ibid",#13
"Ha-Ca-Cb-Hb, Consensus, ibid",#14
"Ha-Ca-Cb-Hb for THR, ibid", #15
"H2N-N2-C2-H2 for GalNAc, JPhysChemB, 2011, 115,11215", #16
"HN-N-Ca-Ha, from David Live, so ask him (BLF)"#17
);
$i=0;
        print "\n\tSelection #\tType & Reference\n";
while ($karplus_table[$i]){
	print "\t$i\t\t$karplus_table[$i]\n";
	$i++;
}
print "\n";
#### Subroutines ##################################################################################################
# The Karplus Equation subroutine
sub karplus {
# $selection ($_[0]) is the Karplus Equation selection number, $torsion ($_[1]) is the torsion value to use in the Karplus Equation
  my ($selection, $torsion) = @_;
  my $jcoup1;

######### J-Coupling Equation Definitions ###################################################
#############################################################################################
##### Single Proton J-Couplings (X-X-X-H) ######################################
if($selection == 0){ # C-O-C-H from  Tvaroska, I., Hricovini, M., Petrakova, E. Carbohydr. Res. 1989, 189, pg 359
        $jcoup1 = 5.7*(cos(($pi*$torsion)/180)**2) - 0.6*cos(($pi*$torsion)/180) + 0.5;
}

elsif($selection == 1){ # C-C-C-H from
        $jcoup1 = 5.8*(cos(($pi*$torsion)/180)**2) - 1.6*cos(($pi*$torsion)/180) + 0.28*sin(2*(($pi*$torsion)/180)) - 0.02*sin(($pi*$torsion)/180) + 0.52;
}
##### End of Single Proton J-Couplings #########################################

################################################################################
##### Two C13 J-Couplings (C-X-X-C) ############################################
elsif($selection==2){ # C1-O5-C5-C6 from Bose et al. JACS 1998, 120, pg 11158-11173
        $jcoup1 = 3.49*(cos(($pi*$torsion)/180)**2) + 0.16;
}
##### End of Two C13 J-Couplings (C-X-X-C) #####################################

################################################################################
##### Two Proton J-Couplings (H-X-X-H) #########################################
elsif($selection==3){ # H-C-C-H from Haasnoot et al. Tetrahedron 1980, 36, pg 2783-2792
        $jcoup1 = 7.76*(cos(($pi*$torsion)/180)**2) - 1.1*(cos(($pi*$torsion)/180)) + 1.4;
}
elsif($selection==4){ # H5-C5-C6-H6R from Stenutz, R., Carmichael, I., Widmalm, G., Serianni, A.S. J. Org. Chem., 2002, 67, pg 949
        $jcoup1 = 5.08 + 0.47*(cos(($pi*$torsion)/180)) + 0.9*(sin(($pi*$torsion)/180)) - 0.12*(cos(2*(($pi*$torsion)/180))) + 4.86*sin(cos(2*(($pi*$torsion)/180)));
}
elsif($selection==5){ # H5-C5-C6-H6S from Stenutz, R., Carmichael, I., Widmalm, G., Serianni, A.S. J. Org. Chem., 2002, 67, pg 949
        $jcoup1 = 4.92 - 1.29*(cos(($pi*$torsion)/180)) + 0.05*(sin(($pi*$torsion)/180)) + 4.58*(cos(2*(($pi*$torsion)/180))) + 0.07*sin(cos(2*(($pi*$torsion)/180)));
}
##### Special Case #######
elsif($selection == 6 or $selection == 7){ # (#6) H-C7-C8-H non-glycosidic from Haasnoot et al. Tetrahedron 1980, 36, pg 2783-2792
# (#7) H-C7-C8-H glycosidic from Haasnoot et al. Tetrahedron 1980, 36, pg 2783-2792
# eqn8: 3JHH = P1*(cos(phi))^2 + P2*cos(phi) + P3 + sum_deltaChi*(P4 + P5*(cos(zeta*phi + P6*abs(deltaChi)))^2)
# eqn9  deltaChi_group = deltaChi(alpha_substituent) - P7*sum(deltaChi_i_beta substituent)
#parameters for equation from Table 2, column 6 (E) with 4 alpha substituents
	my $P1 = 13.24; my $P2 = -0.91; my $P3 = 0.0; my $P4 = 0.53; my $P5 = -2.41; my $P6 = ($pi*15.5)/180; my $P7 = 0.19;

#Pauling's atomic electronegativities and differences
	my $eC = 2.55; my $eH = 2.20; my $eO = 3.44; my $eP = 2.19; my $eN = 3.04;
	my $dXc = $eC - $eH;
	my $dXo = $eO - $eH;
	my $dXp = $eP - $eH;
	my $dXn = $eN - $eH;
#P4, P5, P6 and P7 stuff, and sum electronegativity differences between hydrogen and 
#substituents on C7-C8. Specific to sialic acid glyceryl side chain.
#sum beta substituents. Linkage C7-C8: (C7 = O6,C5 attached to C6)
#                                      (C8 = C2 and O9 attached to O8 and C9, respectively)
#
#                       Terminal C7-C8: (C7 = O6,C5 attached to C6)
#                                       (C8 = O9 attached to C9)
#       group C7 substituents (eqn 9)
#       C6 arm
        my $sum_dXco = $dXc + $dXo;
        my $P7c6 = $P7 * $sum_dXco;
        my $group_c6 = $dXc - $P7c6;
#       group C8 substituents (eqn 9)
#       O8 arm in glycosidic linkage
        my $sum_dXc = $dXc;
        my $P7o8 = $P7 * $sum_dXc;
        my $group_o8g = $dXo - $P7o8;
#       O8 arm in terminal side chain
        my $group_o8t = $dXo;
#       C9 arm
        my $sum_dXo = $dXo;
        my $P7c9 = $P7 * $sum_dXo;
        my $group_c9 = $dXc - $P7c9;
	my $group_o8;

	if($selection==6){ # H-C7-C8-H non-glycosidic from Haasnoot et al. Tetrahedron 1980, 36, pg 2783-2792
        $group_o8 = $group_o8t;
	}
	if($selection==7){ # H-C7-C8-H glycosidic from Haasnoot et al. Tetrahedron 1980, 36, pg 2783-2792
        $group_o8 = $group_o8g;
	}

        my $P123 = $P1*(cos(($pi*$torsion)/180)**2) + $P2*(cos(($pi*$torsion)/180)) + $P3;
        my $P456cm = ($group_c9)*($P4 + $P5*(cos(((-1)*($pi*$torsion)/180) + $P6*abs($group_c9))**2));
        my $P456cp = ($group_c6)*($P4 + $P5*(cos(((1)*($pi*$torsion)/180) + $P6*abs($group_c6))**2));
        my $P456om = ($dXo)*($P4 + $P5*(cos(((-1)*($pi*$torsion)/180) + $P6*abs($dXo))**2));
        my $P456op = ($group_o8)*($P4 + $P5*(cos(((1)*($pi*$torsion)/180) + $P6*abs($group_o8))**2));

#For two carbon and oxygen atoms
        my $T456c = $P456cm + $P456cp; 
        my $T456o = $P456om + $P456op;
        my $T456co = $T456c + $T456o;

        $jcoup1 = $T456co + $P123;
        }

##### End of Special Case#
##### J-Couplings (H1-C-C-H2) A-L-IdoA-2-OSO3 #########################################
elsif($selection==8){ # H-C-C-H from 
        $jcoup1 = 13.24*(cos(($pi*$torsion)/180)**2) - 0.91*(cos(($pi*$torsion)/180)) + 1.98697 - 5.89968*(cos(($pi*$torsion)/180+18.972)**2) - 2.94984*(cos(18.972-($pi*$torsion)/180)**2) - 0.18557*(cos(1.1935-($pi*$torsion)/180)**2);
}
##### J-Couplings (H2-C-C-H3) A-L-IdoA-2-OSO3 #########################################
elsif($selection==9){ # H-C-C-H from 
        $jcoup1 = 13.24*(cos(($pi*$torsion)/180)**2) - 0.91*(cos(($pi*$torsion)/180)) + 1.32871 + 0.22654*(cos(($pi*$torsion)/180+1.457)**2) - 2.94984*(cos(18.972-($pi*$torsion)/180)**2) - 0.18557*(cos(1.1935+($pi*$torsion)/180)**2) - 3.133*(cos(20.15-($pi*$torsion)/180)**2);
}
##### J-Couplings (H3-C-C-H4) A-L-IdoA-2-OSO3 #########################################
elsif($selection==10){ # H-C-C-H from 
        $jcoup1 = 13.24*(cos(($pi*$torsion)/180)**2) - 0.91*(cos(($pi*$torsion)/180)) + 1.41934 - 3.133*(cos(($pi*$torsion)/180+20.15)**2) - 0.37114*(cos(1.1935-($pi*$torsion)/180)**2) - 2.94984*(cos(18.972+($pi*$torsion)/180)**2);
}
##### J-Couplings (H4-C-C-H5) A-L-IdoA-2-OSO3 #########################################
elsif($selection==11){ # H-C-C-H from 
        $jcoup1 = 13.24*(cos(($pi*$torsion)/180)**2) - 0.91*(cos(($pi*$torsion)/180)) + 1.28843 - 0.18557*(cos(($pi*$torsion)/180+1.935)**2) + 0.22654*(cos(($pi*$torsion)/180+1.457)**2) - 5.89968*(cos(18.972-($pi*$torsion)/180)**2);
}
##### J-Couplings (HN-N-Ca-Ha) (Consensus, J. Schmidt, J Mag Res, 2007, 186, pp 34-50 (BLF)) #########################################
elsif($selection==12){ # 
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

############ Standard Deviation Subroutine #####################################################
sub stdev {
        my ($a,$b,$c); ### (total values squared, population(n), average value)
        ($a,$b,$c) = ($_[0],$_[1],$_[2]);
        return (sqrt(( $a - ( $b * (  $c ** 2 ))) / ($b - 1)));
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
	print "\nSelected Karplus Equation No. ".$eqn."\n\t".$karplus_table[$eqn]."\n\n";
}
else {
        print "Please enter the number of the desired Karplus Equation (see table above):";
        $ARGV = <STDIN>;
	$eqn = $ARGV;
        print "\nSelected Karplus Equation No. ".$eqn."\t".$karplus_table[$eqn]."\n\n";
}
$i = 0;
	while(<VAL>){
		my @tmp= split(' ',$_);
#		if($i==0){print "$tmp[1] is the first value\n";}
		$ary[$i]=$tmp[1];
#		print "$ary[$i]\n";
		$i++;
	}
#print "$#ary is the length of \$ary which should be ".($i - 1)."\n";
	close(VAL);
$i=0;

my @pGau;
my @nGau;
my @tRan;
my ($pAvgGau,$nAvgGau,$tAvgRan)=0;
my ($pStdGau,$nStdGau,$tStdRan)=0;

	while( $i <= $#ary){ # Reading through the torsion values
		if($ary[$i] < 0){ $ary[$i] = (360 + $ary[$i]); }
                                if(($ary[$i] >= 0)and($ary[$i] <= 120)){
					$pGau[$pos_gauche] = &karplus($eqn,$ary[$i]); # Storing the J-values in an array for other uses
					$pAvgGau = $pAvgGau + $pGau[$pos_gauche]; # Storing the total values for +Gauche contributions (used to calculate the average & standard deviation)
					$pStdGau = $pStdGau + ($pGau[$pos_gauche])**2; # Storing the total Squared values for the +Gauche contributions (used to calculate standard deviation)
                                        $pos_gauche++; # Counter for the total popn of the +Gauche rotamer
                                }
                                elsif(($ary[$i] > 120)and($ary[$i] <= 240)){
                                        $tRan[$trans] = &karplus($eqn,$ary[$i]);# Storing the J-values in an array for other uses
                                        $tAvgRan = $tAvgRan + $tRan[$trans];# Storing the total Squared values for the trans contributions (used to calculate standard deviation)
                                        $tStdRan = $tStdRan + ($tRan[$trans])**2;# Storing the total Squared values for the trans contributions (used to calculate standard deviation) 
                                        $trans++;# Counter for the total popn of the -Gauche rotamer

                                }
                                elsif(($ary[$i] > 240)and($ary[$i] <= 360)){
                                        $nGau[$neg_gauche] = &karplus($eqn,$ary[$i]); # Storing the J-values in an array for other uses
                                        $nAvgGau = $nAvgGau + $nGau[$neg_gauche]; # Storing the total values for -Gauche contributions (used to calculate the average & standard deviation)
                                        $nStdGau = $nStdGau + ($nGau[$neg_gauche])**2; # Storing the total Squared values for the -Gauche contributions (used to calculate standard deviation)
                                        $neg_gauche++; # Counter for the total popn of the -Gauche rotamer
                                }
		$i++;
	}

my ($JpTotGau,$JnTotGau,$JtTotRan,$JTotGau)=0;
my ($JpStdGau,$JnStdGau,$JtStdRan,$JStdGau)=0;

if($pos_gauche > 0){ # Computing the individual contributions from the +Gauche rotamer
	$JpTotGau=($pAvgGau / $pos_gauche);
	if ($pos_gauche > 1){
		$JpStdGau=&stdev($pStdGau,$pos_gauche,$JpTotGau);
	}
}
if($trans > 0){ # Computing the individual contributions from the Trans rotamer
        $JtTotRan=($tAvgRan / $trans);
        if ($trans > 1){
                $JtStdRan=&stdev($tStdRan,$trans,$JtTotRan);
        }
}
if($neg_gauche > 0){ # Computing the individual contributions from the -Gauche rotamer
        $JnTotGau=($nAvgGau / $neg_gauche);
        if ($neg_gauche > 1){
                $JnStdGau=&stdev($nStdGau,$neg_gauche,$JnTotGau);
        }
}
my $gauche=($pos_gauche + $neg_gauche);
if($gauche > 0){ # Computing the individual contributions from all the Gauche rotamers
	$JTotGau=(($pAvgGau+$nAvgGau)/($gauche));
	if(($gauche) > 1){
		$JStdGau=&stdev(($pStdGau+$nStdGau),$gauche,$JTotGau);
	}
}

my $popn = ($pos_gauche + $trans + $neg_gauche);
my $Jtotal = (($pAvgGau+$tAvgRan+$nAvgGau)/$popn);
my $sqdStd = ($pStdGau+$tStdRan+$nStdGau);
my $Jstd = &stdev($sqdStd,$popn,$Jtotal);


print "Total J-Coupling:\t".sprintf("% .2f",$Jtotal)."\t+/- ".sprintf("% .2f",$Jstd)."\n";
print "\nIndividual Contributions\n";
print "\tGauche:\t".sprintf("% .2f",$JTotGau)." +/- ".sprintf("% .2f",$JStdGau)."\t (".sprintf("%.2f",($gauche/$popn)).")\n";
print "\t\t+Gauche:\t".sprintf("% .2f",$JpTotGau)." +/- ".sprintf("% .2f",$JpStdGau)."\t (".sprintf("%.2f",($pos_gauche/$popn)).")\n";
print "\t\t-Gauche:\t".sprintf("% .2f",$JnTotGau)." +/- ".sprintf("% .2f",$JnStdGau)."\t (".sprintf("%.2f",($neg_gauche/$popn)).")\n";
print "\tTrans:\t".sprintf("% .2f",$JtTotRan)." +/- ".sprintf("% .2f",$JtStdRan)."\t (".sprintf("%.2f",($trans/$popn)).")\n";

