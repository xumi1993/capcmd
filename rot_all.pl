#!/usr/bin/perl
$ddir = $ARGV[0];
`ls -1 $ddir/ground_vel/*.??Z>1.txt`;
my @fl;
my $dir="rot_dir";
open(TXT,"1.txt");
@fl=<TXT>;chomp @fl;close(TXT);unlink "1.txt";
mkdir "$ddir/$dir",0750 unless -d "$ddir/$dir";
foreach $fl (@fl){
	$cmp_h1 = "undef";
        @cmps=split(/\//,$fl);
        $cmp2=$cmps[-1];
        print $fl,"\n", $cmp1,"\n",$cmp2,"\n";
	$tmp=substr($cmp2,0,length($cmp2)-1);
	$tmp2=substr($cmp2,0,length($cmp2)-3);
        $file_e = "$ddir/ground_vel/${tmp}E";
  	$file_n = "$ddir/ground_vel/${tmp}N";
        $file_1 = "$ddir/ground_vel/${tmp}1";
  	$file_2 = "$ddir/ground_vel/${tmp}2";
        if(-f $file_e and -f $file_n){
          $file_h1 = $file_e; $cmp_h1 = "EW"; 
	  $file_h2 = $file_n; 
        }elsif(-f $file_1 and -f $file_2){
	  $file_h1 = $file_1;
	  $file_h2 = $file_2;
        }else{
	  print STDERR "$fl only has vertical component!\n";
	  system("cp $ddir/ground_vel/${tmp}Z $ddir/$dir/${tmp2}z");
          next;
	}
        $junk=`saclst b e cmpinc cmpaz f $file_h1`;
        ($junk,$b1,$e1,$cmpinc1,$cmpaz1)=split(" ",$junk);
        $junk=`saclst b e cmpinc cmpaz f $file_h2`;
        ($junk,$b2,$e2,$cmpinc2,$cmpaz2)=split(" ",$junk);
        $junk=`saclst b e f $ddir/ground_vel/${tmp}Z`;
        ### make minor correction for cmpaz when is needed
        $diff_az = $cmpaz1 - $cmpaz2; 
        if(!(abs($diff_az) eq 90 or abs($diff_az) eq 270)){
          print "$file_h1($cmpaz1) and $file_h2($cmpaz2) are not exactly orthogonal!\n Making correction......\n";
          if(abs($diff_az)>180){
            if($diff_az > 0){
              $corr = $diff_az - 270;
            }else{
              $corr = $diff_az + 270;
            }
          }else{
            if($diff_az > 0){
              $corr = $diff_az - 90;
            }else{
              $corr = $diff_az + 90;
            }
          }
          open(SAC,"|sac");
          if($cmp_h1 eq "EW"){
	    print SAC "r $file_h1\nch cmpaz 90\nwh\n";
	    print SAC "r $file_h2\nch cmpaz  0\nwh\n";
            print SAC "q\n";
          }else{
            $cmpaz1 = $cmpaz1 - $corr;
            $cmpaz1 = $cmpaz1 + 360 if($cmpaz1 < 0);
            $cmpaz1 = $cmpaz1 - 360 if($cmpaz1 >= 360);
            printf SAC "r $file_h1\n ch cmpaz %8.2f\nwh\n",$cmpaz1;
            print SAC "q\n";
          }
          close(SAC);
	} 
        ###
        ### for cmpinc
        if(!($cmpinc1 eq 90 or $cmpinc2 eq 90)){
          open(SAC,"|sac");
            print SAC "r $file_h1 $file_h2\nch cmpinc 90\nwh\nq\n";
          close(SAC);
        }
        ###
        ($junk,$b3,$e3)=split(" ",$junk);
        $b = $b1;$b = $b2 if($b2>$b1 and $b2>$b3);
                 $b = $b3 if($b3>$b1 and $b3>$b2);
        $e = $e1;$e = $e2 if($e2<$e1 and $e2<$e3);
                 $e = $e3 if($e3<$e1 and $e3<$e2);
        $b = $b + 0.1;
        $e = $e - 0.1;
        print $tmp,"\n",$tmp2,"\n";
	open(SAC,"|sac");
        print SAC "cut off\ncut $b $e\n";
	print SAC "r $file_h1 $file_h2  $ddir/ground_vel/${tmp}Z\n";
        print SAC "w over\n";
	print SAC "r $file_h1 $file_h2\n";
	print     "r $file_h1 $file_h2\n";
	print SAC "rot to gcp\n";
    print SAC "lp c 4.5\n";
    print SAC "interpolate delta 0.5\n";
	print SAC "w $ddir/$dir/${tmp2}r $ddir/$dir/${tmp2}t\n";
	print SAC "q\n";
	close(SAC);
	`cp $ddir/ground_vel/${tmp}Z $ddir/$dir/${tmp2}z`; 
 	open(SAC,"|sac");
	print SAC "r $ddir/$dir/${tmp2}z\n";
    print SAC "lp c 4.5\n";
  	print SAC "interpolate delta 0.5\n";
	print SAC "w over\n";
	print SAC "q\n";
	close(SAC);
}
