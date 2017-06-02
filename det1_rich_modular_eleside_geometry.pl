use strict;
use warnings;
our %detector;
our %configuration;
our %parameters;
use Getopt::Long;
use Math::Trig;

my $DetectorMother="root";
my $DetectorName = 'det1_rich_modular_eleside';
# my $hittype="eic_rich";

#require"detector.pl";
require "det1_rich_modular_eleside_module.pl";

sub det1_rich_modular_eleside
{
#------------------- set mRICH wall dimension -------------------#

#     my $rinner=3*1000;              #3m=3000mm
#     my $router=3.7*1000;            #3.7m=3700mm. It doesn't function, just use it for confinement  
    my $rinner=2.2*1000;
    my $router=2.5*1000;

    
    #phi angle cut on the wall dimension
    my $phi_min=0;
#     my $rapidity_max=1.1;
    my $rapidity_max=1.5;
    my $phi_max=2*atan(exp(-$rapidity_max));    #pseudorapidity to polar Angle

    my $gap =1;                      #3mm. to avoid overlapping
    my $halfWidth = getBoxHalf_x()+$gap;  #may add extra width here to increase gap between modules 
    my $halfLength = getBoxHalf_z(); 
#    print "$halfLength\n";  # 137.55625 mm
#    print "$halfWidth\n";    #72.6 mm
    
    if (($router-$rinner)<(2*$halfLength)) {
	print"!!!!!!!!!! det1_rich_modular_eleside >>>> not enough space !!!!!!!!!!\n";
	return 0;
    }

#------------------------ set variables --------------------------#

    my $i; my $j;
    my $x; my $y; my $z;
    my $theta; my $phi; my $deltaPhi;
    my $rotX; my $rotY;
    my $phi_x; my $phi_y; my $angle_max;
    my $n;
    my $name;
    my $count=0;

    $deltaPhi=2*atan($halfWidth/$rinner);
    $n=floor(2*$phi_max/$deltaPhi);
    
    if ($n%2==0) { $angle_max=($n/2)*$deltaPhi-$deltaPhi/2; }               #make the wall symmetric
    else{ $angle_max=(($n-1)/2)*$deltaPhi; }
 
#----- find (x,y,z) and (theta, phi), then build each module -----#

    $i=0;
    for ($phi_x=-$angle_max;$phi_x<$angle_max;$phi_x=$phi_x+$deltaPhi) {
	$x=($rinner+$halfLength)*sin($phi_x);
	
	$j=0;
	for ($phi_y=-$angle_max;$phi_y<$angle_max;$phi_y=$phi_y+$deltaPhi) {
	    
	    $y=($rinner+$halfLength)*sin($phi_y);
	    $z=-sqrt(($rinner+$halfLength)**2-$x**2-$y**2);
	    $phi=acos(-$z/sqrt($x**2+$y**2+$z**2));                          #in radian
	    if ($phi<=($phi_min+$deltaPhi) || $phi>=$phi_max) {              #1) space at the center for beam pipe
	    #if ($phi<=$phi_min || $phi>=$phi_max) {                         #2) tight
	    #if ($phi<=($phi_min+$deltaPhi) || $phi>=$phi_max-$deltaPhi) {   #3) add deltaPhi to create gap
		next;                                                        #   to avoid overlapping
	    }
	    $theta=atan2($y,$x);
	    
	    if ($x!=0 || $y!=0) {
		$rotX=$phi*(-1)*sin($theta)*180/pi;
		$rotY=($phi*(1)*cos(-$theta)+pi)*180/pi;
	    }

	    $name="$DetectorName\_$i\_$j";
# 	    print"$i, $j, name=$name\n";	    
	    $count++;	    
	    modular_rich($name,$x,$y,$z,$rotX,$rotY,$count,"$DetectorName\_0\_0");
	    
	    $j++;
	}
	print"column $i, $j modules built.\n";
	$i++;
    }
    print"----------------------------------------------\n";
    print"total $count modules are built.\n";
}

#---------------------------------------------------------------------#
