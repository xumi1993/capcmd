#!/bin/sh

rdseed -df $1
rdseed -pf $1
ls -1 SAC_* | awk '{split($1,a,"_");print "mv "$1,a[1]"_"a[2]"_"a[3]"_"a[4]"_"a[5]"_"a[6]}' | sh
rm *.10.???.*.SAC
rm SAC_*_10*
