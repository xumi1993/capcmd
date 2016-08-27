#!/usr/bin/env perl
#this prograzm is used to remove the station response from sac files
use strict;
my $ddir=$ARGV[0];
system("ls -1 $ddir/*.?H?>sacfile.txt");
system("ls -1 $ddir/SAC_*>resfile.txt");
system("mkdir $ddir/ground_vel") unless -d "ground_vel";
my (@sacfile,@resfile,$resfile,$sacfile);   #sac file and response files
my @res_name_part;  #the part of sac file and response file
open(SACFILE,"sacfile.txt") or die "can not open sac filelist\n";
open(RESFILE,"resfile.txt") or die "can not open res filelist\n";
@sacfile=<SACFILE>;chomp @sacfile;close(SACFILE);
@resfile=<RESFILE>;chomp @resfile;close(RESFILE);
foreach $sacfile (@sacfile){
	print "begin $sacfile \n";
	my $tmp;   #temporary variable
	foreach $resfile (@resfile){
        	($tmp,$tmp,$tmp,$res_name_part[1],$res_name_part[2],$res_name_part[3])=split(/\_/,$resfile);
		if((index($sacfile,$res_name_part[1]) != -1) and (index($sacfile,$res_name_part[2]) != -1) and (index($sacfile,$res_name_part[3])!=-1)){
			open(SAC,"|sac") or die "can not execute sac\n";
			print SAC "r $sacfile\n";
			print SAC "rmean\n";
			print SAC "rtr\n";
			print SAC "transfer FROM POLEZERO SUBTYPE $resfile TO VEL freq 0.004 0.005 10 12\n";
 			print SAC "rtr\nrmean\n";
			print SAC "mul 100\n";
			print SAC "w $ddir/ground_vel/$sacfile\n";
			print SAC "q\n";
			close(SAC);
			last;
			}
		}
	print "end $sacfile \n";
	}
`rm resfile.txt`;
`rm sacfile.txt`;
