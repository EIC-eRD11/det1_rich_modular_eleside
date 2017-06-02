#############################################################
#############################################################
#
#  Geometry of the 2nd mRICH prototype detector
#  
#  All dimensions are in mm
#  Use the hit type eic_rich 
#  
#  The geometry are divided in 5 parts: 
#  Aerogel, Fresnel lens, Mirrors, Photonsensor, and Readout
#
#############################################################
#############################################################

# LENS=1 : Frensel lens / LENS=0: plano lens

use strict;
use warnings;
use Getopt::Long;
use Math::Trig;
use List::Util qw(min max);
use POSIX;

our %configuration;

my $DetectorMother="root";
my $hittype="eic_rich";

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~ Define detector size and location ~~~~~~~~~~~~~~~~~~~~~~~~~~#
#========================================#
#--------------- swtich -----------------#
my $LENS=0;          #1: Frensel lens / 0: plano lens

my $BoxDelz = 2.0;   #gap ?

#my $maxZ = 2250.0;
#========================================#
#---------------  Aerogel ---------------#
my $agel_halfx = 55.25;
my $agel_halfy = $agel_halfx;
my $agel_halfz = 16.5; #3.3cm thick agel

my $foamHolderThicknessX=10.0;
my $foamHolderThicknessZ=10.0;
my $foamHolder_halfx=$agel_halfx+$foamHolderThicknessX;
my $foamHolder_halfy=$foamHolder_halfx;
my $foamHolder_halfz=$foamHolderThicknessZ/2.0;
#========================================#
#---- Lens: Fresnel lens /Plano lens ----#
#========================================# 
#---- Fresnel lens dimension and info ---#
my $lens_halfx=66.675;   #beam test 2016
my $lens_halfy=$lens_halfx;
my $LensDiameter = 2.0*sqrt(2.0)*$lens_halfx;

my $focalLength=152.4;        #=6"
my $LensEffDiameter =152.4;   #effective diameter in mm.
my $grooveDensity=125/25.4;   #100 grooves per inch. converted to grooves per mm.
my $centerThickness=0.06*25.4;
#my $halfThickness=1.12;       #type in manually after configuration, and then recongfig
my $lens_gap=25.4/8.0;

my $lens_numOfGrooves = floor($grooveDensity*($LensEffDiameter/2));
my $GrooveWidth=1/$grooveDensity;
my $R_min = ($lens_numOfGrooves-1)*$GrooveWidth;
my $R_max = ($lens_numOfGrooves-0)*$GrooveWidth;
#my $lens_halfz = (GetSagita($R_max)-GetSagita($R_min)+$centerThickness)/2.0; #dZ + center thickness

#print"Num. of grooves=",$lens_numOfGrooves," groove width=",$GrooveWidth,"\n";

#---- Plano lens dimension and info -----#
my $planoLens_CT=17;
my $planoLens_ET;
my $planoLens_R=103.4;
my $planoLens_BFL=189.0;
my $planoLens_D=100.0;

#------------ switch lens here ----------#
my @LENSHalfXYZ;
my $LENSFocalLength;
if ($LENS) {
    $LENSHalfXYZ[0]=$lens_halfx;
    $LENSHalfXYZ[1]=$LENSHalfXYZ[0];
    $LENSHalfXYZ[2]=(GetSagita($R_max)-GetSagita($R_min)+$centerThickness)/2.0 ;
    $LENSFocalLength=$focalLength;
    #printf("Num. of grooves=%.6lf, groove width=%.6lf\n",NumberOfGrooves,GrooveWidth);
}
else {
    $LENSHalfXYZ[0]=$planoLens_D/2.0;
    $LENSHalfXYZ[1]=$LENSHalfXYZ[0];
    $LENSHalfXYZ[2]=$planoLens_CT/2.0;
    $LENSFocalLength=$planoLens_BFL;
    #printf("======================== planoLens_ET=%.4lf ===================\n",planoLens_ET);
}
#========================================#
#------------ Photon Sensor -------------#
my $glassWindow_halfx=52/2;
my $glassWindow_halfy= $glassWindow_halfx;
my $glassWindow_halfz= 0.75;  #glass window thickness=1.5mm

my $sensorGap=0.5;             #half the gap between sensor 
my $phodet_halfx = 24.0;       #1/2 eff. area of Hamamatsu H12700a
my $phodet_halfy = $phodet_halfx;
my $phodet_halfz = 0.75;       #Hamamatsu H12700

my $metalSheet_halfx=$glassWindow_halfx;
my $metalSheet_halfy=$metalSheet_halfx;
my $metalSheet_halfz=0.5;     #estimation
my $insulation=27.4;          #gap between sensor and metal sheet

my $sensor_total_halfx=2*$glassWindow_halfx+$sensorGap;   #Glass window larger than sensor
my $build_copper=0;            #1: build copper plate
#========================================#
#---------- Readout electronics ---------#
my $readout_halfz = 4.0;           # I don't like it.
my $readout_thickness=2.0;
#========================================#
#------------- Detector box -------------#
my @all_halfx=($foamHolder_halfx,$LENSHalfXYZ[0],$sensor_total_halfx+$readout_thickness);

my $box_thicknessX=(1.0/4.0)*25.4;    #1/4 inches aluminum sheet
my $box_thicknessZ1=(1.0/16.0)*25.4;
my $box_thicknessZ2=(1.0/4.0)*25.4;

my $box_halfx = max(@all_halfx) + $box_thicknessX+1.0;
my $box_halfy=$box_halfx;
my $box_halfz = ($BoxDelz+2*$foamHolder_halfz+2*$agel_halfz
		 +$lens_gap+2*$LENSHalfXYZ[2]+$LENSFocalLength
		 +2*$glassWindow_halfz+2*$phodet_halfz+(2*$readout_halfz+$BoxDelz)
		 +$box_thicknessZ1+$box_thicknessZ2)/2.0;

if ($build_copper) { $box_halfz = $box_halfz+(1*$metalSheet_halfz+$insulation)/2.0;}

my $offset = $box_halfz+50;     #detector box pos_z

my $hollow_halfx=$box_halfx-$box_thicknessX;
my $hollow_halfy=$hollow_halfx;
my $hollow_halfz=(2.0*$box_halfz-$box_thicknessZ1-$box_thicknessZ2)/2.0;
#========================================#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Math  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
my $hollow_z=-$box_halfz+$hollow_halfz+$box_thicknessZ1;

my $foamHolder_posz=-$hollow_halfz+$BoxDelz+$foamHolder_halfz;
my $agel_posz=$foamHolder_posz+$foamHolder_halfz+$agel_halfz;

#my $lens_z=$agel_posz+$agel_halfz+$lens_halfz+$lens_gap;

my $LENS_z;
my $glassWindow_z;

if ($LENS) {
    $LENS_z=$agel_posz+$agel_halfz+$LENSHalfXYZ[2]+$lens_gap;
    $glassWindow_z=$LENS_z-$LENSHalfXYZ[2]+$LENSFocalLength+$glassWindow_halfz; #out of focus. But this makes sense.
}
else {
    $LENS_z=$agel_posz+$agel_halfz+$lens_gap+$planoLens_R;
    $glassWindow_z=$LENS_z-$planoLens_R+$planoLens_CT+$planoLens_BFL+$glassWindow_halfz;
}

#my $glassWindow_z= $lens_z-$lens_halfz+$focalLength+$glassWindow_halfz;
my $phodet_z =$glassWindow_z+$glassWindow_halfz+$phodet_halfz;
my $metalSheet_z=$phodet_z-$phodet_halfz+$insulation-$metalSheet_halfz;
		     
my @readout_z= ($glassWindow_z-$glassWindow_halfz, $phodet_z+$phodet_halfz);
if ($build_copper) {$readout_z[1]=$metalSheet_z+$metalSheet_halfz+$readout_halfz;}

my $hollowOffset=$hollow_z+$offset;   #accumulated offset due to asymmetric detector walls (z-direction)
my @detposZ = ( $offset, $hollowOffset,$hollowOffset+$agel_posz, $hollowOffset+$LENS_z, $hollowOffset+$phodet_z);

#my @freslens = ( 2.0*sqrt(2.0)*$LensDiameter/8.0, 2.0*sqrt(2.0)*$LensDiameter/8.0, $lens_halfz );
#my @freslens = ( 2.0*sqrt(2.0)*$LensDiameter/8.0, 2.0*sqrt(2.0)*$LensDiameter/8.0, $lens_halfz );
my @readoutposZ = ( $hollowOffset+$readout_z[0], $hollowOffset+$readout_z[1]);
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~ Define the holder Box for Detectors ~~~~~~~~~~~~~~~~~~~~~~~~~#
my $box_name = "detector_holder";
my $box_mat = "G4_Al";
#my $box_mat = "Air_Opt";
#my $box_mat = "holder_acrylic";

my $hollow_mat="Air_Opt";
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
sub getBoxHalf_x()
{
    return $box_halfx;
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
sub getBoxHalf_z()
{
    return $box_halfz;
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
sub modular_rich()
{
    my $myName=$_[0];
    my $X = $_[1];
    my $Y = $_[2];
    my $Z = $_[3];
    my $rotX=$_[4];
    my $rotY=$_[5];
    my $count=$_[6]; 
    my $original=$_[7]; 

    #print"name=$myName\n";
    my %detector=init_det();
    $detector{"name"} = "$myName";
    $detector{"mother"} = "$DetectorMother";
    $detector{"description"} = "$myName";
    $detector{"pos"} = "$X*mm $Y*mm $Z*mm "; #"0*mm 0*mm $offset*mm";
    $detector{"color"} = "81f7f3";
    $detector{"type"} = "Box";
    $detector{"visible"} = "1";
    $detector{"dimensions"} = "$box_halfx*mm $box_halfy*mm $box_halfz*mm";
    $detector{"rotation"} = "$rotX*deg $rotY*deg 0*deg";           #don't put parenthies between quotation marks
    $detector{"material"} = "$box_mat";
    $detector{"sensitivity"} = "no";
    $detector{"hit_type"}    = "no";
    $detector{"identifiers"} = "no";
    print_det(\%configuration, \%detector);
  
    %detector=init_det();
    $detector{"name"} = "$myName\_hollow";
    $detector{"mother"} = "$myName";
    $detector{"description"} = "$myName\_hollow";
    $detector{"pos"} = "0*mm 0*mm $hollow_z*mm";   #w.r.t. detector
    $detector{"color"} = "ffffff";
    $detector{"type"} = "Box";
    $detector{"style"} = "0";
    $detector{"visible"} = "1";
    $detector{"dimensions"} = "$hollow_halfx*mm $hollow_halfy*mm $hollow_halfz*mm";
    $detector{"material"} = "$hollow_mat";
    $detector{"sensitivity"} = "no";
    $detector{"hit_type"}    = "no";
    $detector{"identifiers"} = "no";
    print_det(\%configuration, \%detector);

    build_foamHolder($myName,$count,$original);
    build_aerogel($myName,$count,$original);
    build_lens($myName,$count,$original);
    build_photondet($myName,$count,$original);
    build_mirrors($myName,$count,$original);
    build_readout($myName,$count,$original);

}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Foam holder ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
my $foamHolder_name="FoamHolder";
my $foamHolder_mat="Air_Opt";

sub build_foamHolder()
{
    #print"building foam holder...\n";

    my %detector=init_det();
    $detector{"name"} = "$_[0]\_$foamHolder_name";
    $detector{"mother"} = "$_[0]\_hollow";
    $detector{"description"} = "$_[0]\_$foamHolder_name";
    $detector{"pos"} = "0*mm 0*mm $foamHolder_posz*mm";
    $detector{"color"} = "00ff00";
    if($_[1] == 1){
      $detector{"type"} = "Box";
      $detector{"dimensions"} = "$foamHolder_halfx*mm $foamHolder_halfy*mm $foamHolder_halfz*mm";
    }
    else {  $detector{"type"}       = "CopyOf $_[2]\_$foamHolder_name";}    
    $detector{"material"} = "$foamHolder_mat";
    $detector{"sensitivity"} = "no";
    $detector{"hit_type"}    = "no";
    $detector{"identifiers"} = "no";
    print_det(\%configuration, \%detector);

    my @foamHolder_z=($agel_posz-$agel_halfz,$agel_posz+$agel_halfz);
    my @foamHolder_rinner = ( $agel_halfx, $agel_halfx );
    my @foamHolder_router = ( $agel_halfx+$foamHolderThicknessX, $agel_halfx+$foamHolderThicknessX );

    $detector{"name"} = "$_[0]\_$foamHolder_name\_1";
    $detector{"mother"} = "$_[0]\_hollow";
    $detector{"description"} = "$_[0]\_foamHolder_name";
    $detector{"pos"} = "0*mm 0*mm 0*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = "00ff00";
    #$detector{"style"} = "1";
    if($_[1] == 1){    
      $detector{"type"} = "Pgon";    ### Polyhedra                                                                            
      my $dimen = "45*deg 360*deg 4*counts 2*counts";
      for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $foamHolder_rinner[$i]*mm";}
      for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $foamHolder_router[$i]*mm";}
      for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $foamHolder_z[$i]*mm";}
      $detector{"dimensions"} = "$dimen";
    }
    else {  $detector{"type"}       = "CopyOf $_[2]\_$foamHolder_name\_1";}  
    $detector{"material"} = "$foamHolder_mat";
    $detector{"sensitivity"} = "no";
    $detector{"hit_type"}    = "no";
    $detector{"identifiers"} = "no";
    print_det(\%configuration, \%detector);
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Aerogel ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
my $agel_name = "Aerogel";
my $agel_mat  = "aerogel";
#my $agel_mat  = "G4_WATER";

my $agel_posx=0;
my $agel_posy=0;

sub build_aerogel()
{
    #print"building aerogel block...\n";

    my %detector=init_det();
    $detector{"name"} = "$_[0]\_$agel_name";
    $detector{"mother"} = "$_[0]\_hollow";
    $detector{"description"} = "$_[0]\_$agel_name";
    $detector{"pos"} = "$agel_posx*mm $agel_posy*mm $agel_posz*mm";
    $detector{"color"} = "ffa500";
    $detector{"style"} = 1;
    if($_[1] == 1){    
      $detector{"type"} = "Box";
      $detector{"dimensions"} = "$agel_halfx*mm $agel_halfy*mm $agel_halfz*mm";
    }
    else {  $detector{"type"}       = "CopyOf $_[2]\_$agel_name";}     
    $detector{"material"} = "$agel_mat";
    $detector{"sensitivity"} = "$hittype";
    $detector{"hit_type"}    = "$hittype";
    my $id=2000000+$_[1]*100000;
    $detector{"identifiers"} = "id manual $id";
    print_det(\%configuration, \%detector);
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Fresnel lens ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
my $lens_numOfHoldBox = 4;        #number of hold box for fresnel lens
#my $lens_holdbox_name="$DetectorName\_lensHoldBox";
my $lens_holdbox_mat  = "Air_Opt";

my $lens_mat  = "acrylic";
my $max_numOfGrooves=1000;

#========================================#
#---------- build Fresnel Lens ----------#
sub build_lens()
{
    #print"building Fresnel Lens... It takes some time\n";
    #print"\tFresnel Lens: num. of grooves = $lens_numOfGrooves\n";
    #print"\tFresnel Lens: Lens diameter = $LensDiameter\n";
    #print"\tFresnel Lens: effective diameter = $LensEffDiameter mm \n";

    #========================================#
    #----- holder box for fresnel lens ------#
    my $lens_holdbox_halfz=$LENSHalfXYZ[2];
    #print"\tholdbox half thickness= ",$lens_holdbox_halfz,"\n";
    #my @lens_holdbox_rotZ = ( -270, -180, -90, 0 );
    #========================================#
    #----------- build holder box -----------#
    my %detector; 
    %detector=init_det();
    $detector{"name"} = "$_[0]\_lensHoldBox";
    $detector{"mother"} = "$_[0]\_hollow";
    $detector{"description"} = "$_[0]\_lensHoldBox";
    $detector{"pos"} = "0*mm 0*mm $LENS_z*mm";
    $detector{"rotation"} = "0*deg -180*deg 0*deg";    
    if($_[1] == 1){
      $detector{"type"} = "Box";
      $detector{"dimensions"} = "$lens_halfx*mm $lens_halfy*mm $lens_holdbox_halfz*mm";
    }
    else {  $detector{"type"}       = "CopyOf $_[2]\_lensHoldBox";}
    $detector{"color"} = "2eb7ed";
    $detector{"material"} = $lens_holdbox_mat;    
    $detector{"style"} = "0";    
    $detector{"visible"} = "1";
    $detector{"sensitivity"} = "no";
    $detector{"hit_type"}    = "no";
    $detector{"identifiers"} = "no";
    print_det(\%configuration, \%detector);
    
    #========================================#
    #------------ build grooves -------------#
    if($_[1] == 1){    
    for(my $igroove=0; $igroove<$max_numOfGrooves; $igroove++){
	#--------------------------------------------------------#
	#Grooves' inner and outer radius
	my $iRmin1 = ($igroove+0)*$GrooveWidth;
	my $iRmax1 = ($igroove+1)*$GrooveWidth;
	my $iRmin2 = $iRmin1;
	my $iRmax2 = $iRmin2+0.0001;
	
	my @lens_poly_rmin = ($iRmin1, $iRmin1, $iRmin2);
        my @lens_poly_rmax = ($iRmax1, $iRmax1, $iRmax2);

	if ($iRmax1>$LensDiameter/2.0) { last; }    #if iRmin1>Lens radius, outside the lens, break
	#--------------------------------------------------------#
	#phi angle (from Ping)
	my $phi1;
	my $phi2;
	my $deltaPhi;
	
	if ($iRmax1<$lens_halfx) {   #1/4 of a full circle
	    $phi1=0;                 #in degree
	    $deltaPhi=360;           #in degree
	}
	else {
	    $phi1=acos($lens_halfx/$iRmax1)*180/pi;   #in degree
	    $phi2=asin($lens_halfy/$iRmax1)*180/pi;   #in degree
	    $deltaPhi=$phi2-$phi1;
	    #if ($iholdbox==0) {print "this is ", $igroove, "th grooves, phi1=",$phi1,", delPhi=",$deltaPhi,"\n";}
	}
	#--------------------------------------------------------#
	#grooves profile
	my $dZ=0.06*25.4;                     #center thickness=0.06 inches
	my @lens_poly_z;
	my $numOfLayer;

	if ($iRmin1<$LensEffDiameter/2.0) {   #if iRmin>=effective radius, dZ=0, i.e. flat
	    $numOfLayer=3;
	    $dZ = GetSagita($iRmax1) - GetSagita($iRmin1);
	    #print "alpha=",atan($GrooveWidth/$dZ)*180/pi," deg\n";
	    if($dZ<=0) { print "build_lens::Groove depth<0 !\n"; }
	    @lens_poly_z    = (-1*$LENSHalfXYZ[2], $LENSHalfXYZ[2]-$dZ, $LENSHalfXYZ[2]);
	}
	else {
	    $numOfLayer=2;
	    @lens_poly_z    = (-1*$LENSHalfXYZ[2], -1*$LENSHalfXYZ[2]+$dZ);
	}
	#--------------------------------------------------------#
	my $repeat=1;
	my $draw=0;
	my $grooveName="$_[0]\_lensHoldBox\_groove$igroove";
	
	if ($iRmax1>=$lens_halfx) { $repeat=4; }   #4 edges
	for (my $i=0;$i<$repeat;$i++) {
	    if ($repeat==4) { $grooveName="$_[0]\_lensHoldBox\_groove$igroove\_edge$i"; }
	    
	    my $dimen;
	    $dimen = "$phi1*deg $deltaPhi*deg $numOfLayer*counts";                  #Ping
	    for(my $i = 0; $i <$numOfLayer; $i++) {$dimen = $dimen ." $lens_poly_rmin[$i]*mm";}
	    for(my $i = 0; $i <$numOfLayer; $i++) {$dimen = $dimen ." $lens_poly_rmax[$i]*mm";}
	    for(my $i = 0; $i <$numOfLayer; $i++) {$dimen = $dimen ." $lens_poly_z[$i]*mm";}
	    
	    %detector=init_det();
	    $detector{"name"} = "$grooveName";
	    $detector{"mother"} = "$_[0]\_lensHoldBox";
	    $detector{"description"} = "$grooveName";
	    $detector{"pos"} = "0*mm 0*mm 0*mm";   #w.r.t. lens hold box
	    $detector{"color"} = "2eb7ed";
	    $detector{"type"} = "Polycone";
	    $detector{"dimensions"} = "$dimen";
	    $detector{"material"} = "$lens_mat";
	    $detector{"style"} = "1";
	    $detector{"visible"} = "$draw";
	    $detector{"sensitivity"} = "no";
	    $detector{"hit_type"}    = "no";
	    $detector{"identifiers"} = "no";
	    print_det(\%configuration, \%detector);
	    
	    $phi1=$phi1+90;
	}
    }
    }
}
#========================================#
#------- arc shape, spherical lens ------#
sub GetSagita
{
  my $Conic = -1.0;		      #original
  #my $lens_type = 3;
  my $lens_type = 5;                  #spherical Fresnel lens
  my $Curvature;
  my @Aspher = (0, 0, 0, 0, 0, 0, 0, 0 );
  my $n=1.49;                         #refractive index of Fresnel lens
  
  if ($lens_type == 1) {
      $Curvature = 0.00437636761488;
      $Aspher[0] = 4.206739256e-05;
      $Aspher[1] = 9.6440152e-10;
      $Aspher[2] = -1.4884317e-15;
  }
  
  if ($lens_type == 2) {	       #r=77mm, f~14cm
      $Curvature = 0.0132;
      $Aspher[0] = 32.0e-05;
      $Aspher[1] = -2.0e-7;
      $Aspher[2] =  1.2e-13;
  }
  
  if ($lens_type == 3) {	       #r=77mm, f~12.5cm
      $Curvature = 0.0150;
      $Aspher[0] = 42.0e-05;
      $Aspher[1] = -3.0e-7;
      $Aspher[2] =  1.2e-13;
  }
  if ($lens_type == 4) {	       #r=77mm, f~10cm
      $Curvature = 0.0175;
      $Aspher[0] = 72.0e-05;
      $Aspher[1] = -5.0e-7;
      $Aspher[2] =  1.2e-13;
  }
  if  ($lens_type == 5) {              #Ping: curvature=1/(focalLength*(n-1))
      #$Curvature=0.0267;
      #$Curvature=0.0287;   
      $Curvature=1/($focalLength*($n-1));
  }
  
  my $TotAspher = 0.0;
  for(my $k=1;$k<9;$k++){ $TotAspher += $Aspher[$k-1]*($_[0]**(2*$k)); }
  
  my $ArgSqrt = 1.0-(1.0+$Conic)*($Curvature**2)*($_[0]**2);
  if ($ArgSqrt < 0.0){ print "build_lens::Sagita: Square Root of <0 ! \n"; }
  
  my $Sagita_value = $Curvature*($_[0]**2)/(1.0+sqrt($ArgSqrt)) + $TotAspher;
  return $Sagita_value ;
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ photon sensor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
my $photondet_name = "Photondet";
#my $photondet_mat  = "Aluminum";
my $photondet_mat  = "Air_Opt";

my $last_x=$glassWindow_halfx+$sensorGap;
my $last_y=$last_x;   #1st quandrant
sub build_photondet()
{
    #print"building photonsensor...\n";
    #print"\t",'gap=',$last_x-$phodet_halfx,"\n";
    my $photondet_x;
    my $photondet_y;

    for (my $i=1;$i<5;$i++) {
	#--------------------------------------------------------#
	# change quandrant                                                                                                    
	if ($i==0) {
	    $photondet_x=$last_x;
	    $photondet_y=$last_y;
	}
	else {
	    $photondet_x=-$last_y;
	    $photondet_y=$last_x;
	}
	#--------------------------------------------------------#     

	#========================================#
	#--------- build glass window -----------#
	my %detector=init_det();
	$detector{"name"} = "$_[0]\_glassWindow$i";
	$detector{"mother"} = "$_[0]\_hollow";
	$detector{"description"} = "$_[0]\_glassWindow$i";
	$detector{"pos"} = "$photondet_x*mm $photondet_y*mm $glassWindow_z*mm";
	$detector{"rotation"} = "0*deg 0*deg 0*deg";
	$detector{"color"} = "1ABC9C";
	#$detector{"style"} = "1";
	if($_[1] == 1){    
	    $detector{"type"} = "Box";
	    $detector{"dimensions"} = "$glassWindow_halfx*mm $glassWindow_halfy*mm $glassWindow_halfz*mm";
	}
	else {  $detector{"type"}       = "CopyOf $_[2]\_glassWindow$i";}   	
	$detector{"material"} = "glass";
	#$detector{"material"} = "Air_Opt";
	$detector{"mfield"} = "no";
	$detector{"sensitivity"} = "no";
	$detector{"hit_type"}    = "no";
	$detector{"identifiers"} = "no";
	print_det(\%configuration, \%detector);
	
	#========================================#
	#------------ build sensor --------------#
	%detector=init_det();
	$detector{"name"} = "$_[0]\_$photondet_name\_$i";
	$detector{"mother"} = "$_[0]\_hollow";
	$detector{"description"} = "$_[0]\_$photondet_name\_$i";
	$detector{"pos"} = "$photondet_x*mm $photondet_y*mm $phodet_z*mm";
	$detector{"rotation"} = "0*deg 0*deg 0*deg";
	$detector{"color"} = "0000A0";
	$detector{"style"} = "1";
	if($_[1] == 1){    
	  $detector{"type"} = "Box";
	  $detector{"dimensions"} = "$phodet_halfx*mm $phodet_halfy*mm $phodet_halfz*mm";
	}
	else {  $detector{"type"}       = "CopyOf $_[2]\_$photondet_name\_$i";}   		
	$detector{"material"} = "$photondet_mat";
	$detector{"mfield"} = "no";
	$detector{"sensitivity"} = "$hittype";
	$detector{"hit_type"}    = "$hittype";
	my $id=2000000+$_[1]*200000+$i*10000;
	$detector{"identifiers"} = "id manual $id";
	print_det(\%configuration, \%detector);
	
	#print'photondet_x=',$photondet_x,', photondet_y=',$photondet_y,"\n"; 

        $last_x=$photondet_x;
        $last_y=$photondet_y;
    }# end of for loop
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ reflection mirrors ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
my $mirror_mat  = "Aluminum";
sub build_mirrors()
{
    #print"building mirror set...\n";

    my $mirror_thickness=2;
    #my @mirror_z=($lens_z+$lens_halfz+$lens_gap,$glassWindow_z-$glassWindow_halfz);
    my @mirror_z=($glassWindow_z-$glassWindow_halfz-$LENSFocalLength,$glassWindow_z-$glassWindow_halfz);
    my @mirror_router = ( $agel_halfx+$mirror_thickness, $sensor_total_halfx+$mirror_thickness );
    my @mirror_rinner = ( $agel_halfx, $sensor_total_halfx);
    
    #print"\t",'mirror: length in z direction =',$mirror_z[1]-$mirror_z[0],"\n";

    my $idManual=3;
    my %detector=init_det();
    $detector{"name"} = "$_[0]\_mirror";
    $detector{"mother"} = "$_[0]\_hollow";
    $detector{"description"} = "$_[0]\_mirror";
    $detector{"pos"} = "0*mm 0*mm 0*mm";
    $detector{"color"} = "ffff00";
    if($_[1] == 1){    
      $detector{"type"} = "Pgon";
      my $dimen = "45*deg 360*deg 4*counts 2*counts";
      for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $mirror_rinner[$i]*mm";}
      for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $mirror_router[$i]*mm";}
      for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $mirror_z[$i]*mm";}	
      $detector{"dimensions"} = "$dimen";
    }
    else {  $detector{"type"}       = "CopyOf $_[2]\_mirror";} 	
    $detector{"material"} = "$mirror_mat";
    $detector{"sensitivity"} = "mirror: rich_mirrors";
    $detector{"hit_type"}    = "no";
    $detector{"identifiers"} = "no";
    print_det(\%configuration, \%detector);
    

}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ readout hardware ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
my $readoutdet_name = "readout";
my $readout_mat  = "Aluminum";
my @readoutdet_pos  = ( 0.0, 0.0, 0.0 );
my @readout_rinner = ( $sensor_total_halfx, $sensor_total_halfx ); 
my @readout_router = ( $sensor_total_halfx+$readout_thickness, $sensor_total_halfx+$readout_thickness );


sub build_readout()
{
    #print"building readout hardware...\n";
   
    my %detector=init_det();
    $detector{"name"} = "$_[0]\_$readoutdet_name";
    $detector{"mother"} = "$_[0]\_hollow";
    $detector{"description"} = "$_[0]\_$readoutdet_name";
    $detector{"pos"} = "$readoutdet_pos[0]*mm $readoutdet_pos[1]*mm $readoutdet_pos[2]*mm"; #Ping : checked
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = "ff0000";
    #$detector{"style"} = "1";
    if($_[1] == 1){        
      $detector{"type"} = "Pgon";    ### Polyhedra
      my $dimen = "45*deg 360*deg 4*counts 2*counts";
      for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $readout_rinner[$i]*mm";}
      for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $readout_router[$i]*mm";}
      for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $readout_z[$i]*mm";}
      $detector{"dimensions"} = "$dimen";
    }
    else {  $detector{"type"}       = "CopyOf $_[2]\_$readoutdet_name";} 	
    $detector{"material"} = "$readout_mat";
    $detector{"sensitivity"} = "no";
    $detector{"hit_type"}    = "no";
    $detector{"identifiers"} = "no";
    print_det(\%configuration, \%detector);
    
}
