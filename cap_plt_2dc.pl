# this subroutine plots waveform fits produced by source inversion srct

#$pssac = "/opt/util/autorun/files/pssac2";
$pssac = "pssac2";
sub plot {
  system("gmtset MEASURE_UNIT cm");
  system("gmtset ANNOT_OFFSET_PRIMARY 0.1");
  system("gmtset ANNOT_FONT_SIZE_PRIMARY 8p");
  system("gmtset HEADER_FONT_SIZE 10p");
  system("gmtset LABEL_FONT_SIZE 10p");
  system("gmtset LABEL_OFFSET 0.0");
  local($model, $t1, $t2, $am, $num_com, $sec_per_inch,$c1,$c2,$c3,$c4) = @_;
  local($nn,$tt,$plt1,$plt2,$plt3,$plt4,$i,$nam,$com1,$com2,$j,$x,$y,@aa,$rslt,@name,@aztk,@dist);
  local $keepBad = 0;
   
  open(TTT,"> aztk.txt");  

  @trace = ("1/255/255/255","3/0/0/0");       # plot data trace
  @name = ("Pnl V","Pnl R","Vertical.","Radial","Tang.");
  
  ($nn,$hight) = (10,26.5);	# 10 rows of traces per 10.5 in.
  
  $sepa = 0.1*$sec_per_inch;
#  $tt = 2*$t1 + ($num_com-2)*$t2+($num_com-1)*$sepa;
  $tt = $t1 + $t2+($num_com-1)*$sepa*2;
  $width = 0.1*int(10*$tt/$sec_per_inch+0.5);
  printf "width= $width\n,hight=$hight\n";
#  @x0 = ($t1+$sepa, $t1+$sepa, $t2+$sepa, $t2+$sepa, $t2);
  @x0 = ($t1+$sepa, 2*$sepa, 2*$sepa, 2*$sepa, $t2);
  
  $plt1 = "| $pssac -JX$width/$hight -R0/$tt/0/$nn -Y1.0 -Ent-2 -W0.5p -M$am/0 -K -P >> $model.ps";
  $plt2 = "| pstext -JX -R -O -K -N >> $model.ps";
  $plt3 = "| psmeca -JX1/1 -R-1/1/-1/1 -Sa5 -Y24.7 -X-0.8 -O -K -G255/0/0>> $model.ps";
  $plt4 = "| psxy -JPa1 -R0/360/0/1 -Sc0.05 -W4/0/0/0 -G255/255/255 -O -K -N >> $model.ps";
  $B_sec_per_inch=0.5*$sec_per_inch;
  $ttt = $sec_per_inch * 2;
  $plt5 = "psbasemap -JX2/0.5 -R0/$ttt/0/0.5 -X0.8 -Y-1.6 -P -O -B$sec_per_inch:'sec':N >> $model.ps";

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
	if ($aa[5*$j+2]>0) {
	   printf PLT "%s %f %f 3/0/0/0\n",$nam.$com1,$x,$nn-$i-2; ## plot the data.
           printf PLT "%s %f %f 3/255/0/0\n",$nam.$com2,$x,$nn-$i-2; ## plot the synthetic waveform data.
	} elsif ($keepBad) {
	   printf PLT "%s %f %f 3/0/255/0\n",$nam.$com1,$x,$nn-$i-2;
           printf PLT "%s %f %f 3/255/0/0\n",$nam.$com2,$x,$nn-$i-2; ## plot the synthetic waveform data.
	}

        $x = $x + $x0[$j];
        $com1-=2;
        $com2-=2;
      }
      $aztk[$i] = `saclst az user1 f ${nam}0`;
      $dist[$i] = `saclst dist f ${nam}0`;
      $i++;
    }
    close(PLT);
    
    open(PLT, $plt2);
    $y = $nn-2;
    $i = 0;
    foreach (@aaaa) {
      @bb = split(/\s+/,$aztk[$i]);
#      $bb[1]=substr($bb[1],0,4);
      @cc = split(/\s+/,$dist[$i]);
#      $cc[1]=substr($cc[1],0,4);
      @aa = split;
      $x = $sepa;
      printf PLT "%f %f 10 0 0 1 $aa[0]\n",$x-1.0*$sec_per_inch,$y; ##plot the station name in the left "BBS_";
      printf PLT "%f %f 10 0 0 1 %6.2f\n",$x-1.0*$sec_per_inch,$y-0.25,$bb[1];
      printf PLT "%f %f 10 0 0 1 %6.2f\n",$x-1.0*$sec_per_inch,$y+0.25,$cc[1] if($cc[1]<3000);
      printf PLT "%f %f 10 0 0 1 %6.2f\n",$x-1.0*$sec_per_inch,$y+0.25,$cc[1]/111.1 if($cc[1]>=3000);
      for($j=0;$j<$num_com;$j++) {
	if ($aa[5*$j+2]>0) {
        printf PLT "%f %f 10 0 0 1 $aa[5*$j+6]\n",$x+0.1,$y-0.4;
        printf PLT "%f %f 10 0 0 1 $aa[5*$j+4]\n",$x+0.1,$y-0.6;
	} elsif ($keepBad) {
        printf PLT "%f %f 10 0 0 1 $aa[5*$j+6]\n",$x+0.1,$y-0.4;
        printf PLT "%f %f 10 0 0 1 $aa[5*$j+4]\n",$x+0.1,$y-0.6;
	}

        $x = $x + $x0[$j];
      }
      $y--;
      $i++;
    }
    printf PLT "%f %f 10 0 0 1 @meca\n",0.5*$sec_per_inch,$nn-0.5;
    printf PLT "%f %f 10 0 0 1 Frequency band for Pnl: $c1 ~ $c2(Hz)  	Frequency band for Surface Wave: $c3 ~ $c4(Hz)\n",0.5*$sec_per_inch,$nn-0.75;
    $x = 0.2*$sec_per_inch;
#    for($i=0;$i<$num_com;$i++) {
#      printf PLT "%f %f 9 0 0 1 $name[$i]\n",$x-1,$nn-1.60;
#      $x = $x+$x0[$i];
#    }
      printf PLT "%f %f 9 0 0 1 $name[0]\n",$x-1,$nn-1.60;
      $x = $x+$x0[4];
      printf PLT "%f %f 9 0 0 1 $name[4]\n",$x-1,$nn-1.60;
    close(PLT);

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
    foreach (@aztk) {
      @aa = split;
      @bb = split(/\_/,$aa[0]);
      if ($aa[2]>90.) {$aa[1] += 180;}# $aa[2]=180-$aa[2];}
      #printf PLT "$aa[1] %f\n",sqrt(2.)*sin($aa[2]*3.14159/360);
      printf PLT "$aa[1] %f\n",sin($aa[2]*3.14159/360);
    }
    close(PLT);
    print TTT @aztk;
    system("$plt5");
#    open(PLT,"|$plt5");
#    close(PLT);
  }
  close(TTT);
}
1;
