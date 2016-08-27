#!/bin/sh

dir=$1/rot_dir

taup_setsac -mod prem -ph p-6,s-7,PcP-8,ScS-9 -evdpkm $dir/*.[rtz]
taup_setsac -mod prem -ph P-6,S-7,PcP-8,ScS-9 -evdpkm $dir/*.[rtz]

saclst t6 t7 f $dir/*.[rtz] > t1t3.table

cat t1t3.table | awk '{
print "r "$1;
print "ch t1 "$2-10;
print "ch t2 "$2+50;
print "ch t3 "$3-10;
print "ch t4 "$3+100; 
print "wh";
print "lp c 0.8";
print "interp delta 0.5";
print "w over";} 
END {print "quit"}' | sac 

