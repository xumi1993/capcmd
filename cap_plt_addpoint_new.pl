# this subroutine plots waveform fits produced by source inversion srct

$pssac = "pssac2";
sub plot {
  system("gmtset MEASURE_UNIT cm");
  local($model, $t1, $t2, $am, $num_com, $sec_per_inch,$c1,$c2,$c3,$c4) = @_;
  local($nn,$tt,$plt1,$plt2,$plt3,$plt4,$i,$nam,$com1,$com2,$j,$x,$y,@aa,$rslt,@name,@aztk,@dist);
  local $keepBad = 1;
   
  open(TTT,"> aztk.txt");  

  @trace = ("1/255/255/255","3/0/0/0");       # plot data trace
  @name = ("Pnl V","Pnl R","Vertical.","Radial","Tang.");
  
  ($nn,$hight) = (12,26.5);	# 10 rows of traces per 10.5 in.
  
  $sepa = 0.1*$sec_per_inch;
  $tt = 2*$t1 + ($num_com-2)*$t2+($num_com-1)*$sepa;
  $width = 0.1*int(10*$tt/$sec_per_inch+0.5);
  printf "width= $width\n,hight=$hight\n";
  @x0 = ($t1+$sepa, $t1+$sepa, $t2+$sepa, $t2+$sepa, $t2);
  
  $plt1 = "| $pssac -JX$width/$hight -R0/$tt/0/$nn -Y1.0 -Ent-2 -W0.5p -M$am/1 -K -P >> $model.ps";
#  $plt1 = "| $pssac -JX$width/$hight -R0/$tt/0/$nn -Y0.2 -Ent-2 -W40 -M$am/0.1 -K -P>> $model.ps";
  $plt2 = "| pstext -JX -R -O -K -N >> $model.ps";
  $plt3 = "| psmeca -JX1/1 -R-1/1/-1/1 -Sa5 -Y24.7 -X-0.8 -O -K -G255/0/0>> $model.ps";
  $plt4 = "| psxy -JPa1 -R0/360/0/1 -Sc0.05 -W4/0/0/0 -G255/255/255 -O -N >> $model.ps";
#  $plt4 = "| psxy -JPa1 -R0/360/0/1 -Sc0.05 -W4/0/0/0  -O -N >> $model.ps";
  $B_sec_per_inch=0.5*$sec_per_inch;
  $plt5 = "| psxy -JX1/0.5 -R0/$sec_per_inch/0/0.5 -Y3.5 -P -O -K -B$B_sec_per_inch:'t(sec)':S >> $model.ps";
#    `echo "0 $sec_per_inch" | psxy -JX1/0.5 -R0/$sec_per_inch/0/1 -Y3.5 -X4 -O -P -K -B$sec_per_inch::S >> $model.ps`;
  #$plt22 = "| pstext -JP -R -O -N -G255/0/0 -K>> $model.ps";
  #$plt1=$plt2=$plt3="|cat";		# for testing

  open(FFF,"$model.out");
  @rslt = <FFF>;
  close(FFF);
  @meca = split('\s+',shift(@rslt));
  @others = grep(/^#/,@rslt); @rslt=grep(!/^#/,@rslt);

  unlink("$model.ps") if -e "$model.ps";
  while (@rslt) {
    open(PLT, $plt1);
    $i = 0; @aztk=();
    @aaaa = splice(@rslt,0,$nn-2);
    foreach (@aaaa) {
      @aa = split;
      $nam = "${model}_$aa[0].";
      $x=0;
      $com1=2*($num_com-1);
      $com2=$com1+1;
      for($j=0;$j<$num_com;$j++) {
        #printf PLT "%s %f %f $trace[$aa[4*$j+2]>0]\n",$nam.$com1,$x,$nn-$i-2;
	if ($aa[5*$j+2]>0) {
	   printf PLT "%s %f %f 3/0/0/0\n",$nam.$com1,$x,$nn-$i-2; ## plot the data.
#	   printf "$plt1 %s %f %f 5/0/0/0\n",$nam.$com1,$x,$nn-$i-3;
	} elsif ($keepBad) {
	   printf PLT "%s %f %f 3/0/255/0\n",$nam.$com1,$x,$nn-$i-2;
	}
     #   printf PLT "%s %f %f 3/255/0/0\n",$nam.$com2,$x,$nn-$i-3;
        printf PLT "%s %f %f 3/255/0/0\n",$nam.$com2,$x,$nn-$i-2; ## plot the synthetic waveform data.
#        printf  "$plt %s %f %f 30/255/0/0\n",$nam.$com2,$x,$nn-$i-3; ## plot the synthetic waveform data.
        $x = $x + $x0[$j];
        $com1-=2;
        $com2-=2;
      }
      $aztk[$i] = `saclst az user1 f ${nam}0`;
      $dist[$i] = `saclst dist f ${nam}0`;
#      print "az $i = $aztk[$i] \n ";
      $i++;
    }
    close(PLT);
    
    open(PLT, $plt2);
    $y = $nn-2;
    $i = 0;
    foreach (@aaaa) {
      @bb = split(/\s+/,$aztk[$i]);
      $bb[1]=substr($bb[1],0,4);
      @cc = split(/\s+/,$dist[$i]);
      $cc[1]=substr($cc[1],0,4);
#      printf "az = $bb[1] \n";
#      printf "dist = $cc[1]\n";
      @aa = split;
#      printf "aa = $aa[0] \n";
      $x = 0;

      printf PLT "%f %f 10 0 0 1 $aa[0]\n",$x-0.6*$sec_per_inch,$y; ##plot the station name in the left "BBS_";
      printf PLT "%f %f 10 0 0 1 $bb[1]\n",$x-0.6*$sec_per_inch,$y-0.25;
      printf PLT "%f %f 10 0 0 1 $cc[1]\n",$x-0.6*$sec_per_inch,$y+0.25;
#      printf PLT "%f %f 10 0 0 1 $aa[1]\n",$x-0.4*$sec_per_inch,$y-0.25; ##plot the time shift of each events, under-right size.
      for($j=0;$j<$num_com;$j++) {
        printf PLT "%f %f 10 0 0 1 $aa[5*$j+6]\n",$x+0.1,$y-0.4;
#        printf PLT "%f %f 10 0 0 1 $aa[5*$j+4] $aa[5*$j+5]\n",$x,$y-0.6;
        printf PLT "%f %f 10 0 0 1 $aa[5*$j+4]\n",$x+0.1,$y-0.6;
        $x = $x + $x0[$j];
      }
      $y--;
      $i++;
    }
#    printf PLT "%f %f 11 0 1 LM Event %s  Model_depth %s  FM %-3d %-3d %-3d  Mw %4.2f  Error %s\n",-0.4*$sec_per_inch,$nn-1,@meca[1,3,5,6,7,9,11];
    printf PLT "%f %f 10 0 0 1 @meca\n",0.5*$sec_per_inch,$nn-0.5;
    printf PLT "%f %f 10 0 0 1 Frequency band for Pnl: $c1 ~ $c2(Hz)  	Frequency band for Surface Wave: $c3 ~ $c4(Hz)\n",0.5*$sec_per_inch,$nn-0.75;
    $x = 0.2*$sec_per_inch;
    for($i=0;$i<$num_com;$i++) {
      printf PLT "%f %f 9 0 0 1 $name[$i]\n",$x-1,$nn-1.60;
      $x = $x+$x0[$i];
    }
    close(PLT);
#    `echo "0 $sec_per_inch" | psxy -JX1 -R0/$sec_per_inch/0/1 -Y4 -X -O -K -B$sec_per_inch::S >> $model.ps`;
#    open(PLT,$plt5);
#    printf "0 %d\n",$sec_per_inch;
#    close(PLT);

    if($meca[6] > 90) {
       $meca[5] += 180;
       $meca[6] = 180-$meca[6];
       $meca[7] = -1*$meca[7];
    } 

    open(PLT, $plt3);
    printf PLT "0 0 0 @meca[5,6,7] 1\n";#0.5*$sec_per_inch,$nn-1;
    print "strike dip slip:  $meca[5]  $meca[6]  $meca[7]\n";
    $x = 2;
    foreach (@others) {
       split;
       if($_[2] > 90) {
          $_[1] += 180;
          $_[2] = 180 - $_[2];
          $_[3] = -1*$_[3];
       }
       printf PLT "%f -0.2 0 @_[1,2,3] 0.5 $_[4]\n",$x; $x+=1.5;
       printf  "%f -0.2 0 @_[1,2,3] 0.5 $_[4]\n",$x; $x+=1.5;
    }
    close(PLT);
    open(PLT, $plt4);
   # open(PLT2,$plt22);
    foreach (@aztk) {
      @aa = split;
      @bb = split(/\_/,$aa[0]);
      if ($aa[2]>90.) {$aa[1] += 180; $aa[2]=180-$aa[2];}
   
      	
      printf PLT "$aa[1] %f\n",sqrt(2.)*sin($aa[2]*3.14159/360);
      
   #   printf PLT2 "%f %f 8 0 0 1 $bb[2]\n",$aa[1],sqrt(2.)*sin($aa[2]*3.14159/360);
    }
    close(PLT);
  #  close(PLT2);
    print TTT @aztk;
  }
  close(TTT);
}
1;
