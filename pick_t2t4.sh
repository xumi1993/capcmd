#!/bin/sh

dir=$1/data

taup_setsac -mod prem -ph p-1,s-3,PcP-8,ScS-9 -evdpkm $dir/*.[rtz]
taup_setsac -mod prem -ph P-1,S-3,PcP-8,ScS-9 -evdpkm $dir/*.[rtz]

saclst t1 t3 f $dir/*.[rtz] > t1t3.table

cat t1t3.table | awk '{
print "r "$1;
print "ch t1 "$2-5;
print "ch t2 "$2+75;
print "ch t3 "$3-10;
print "ch t4 "$3+75; 
print "wh";} 
END {print "quit"}' | sac 

