#!/bin/sh

rdseed -df $1
rdseed -pf $1
ls -1 SAC_* | awk '{split($1,a,"_");print "mv "$1,a[1]"_"a[2]"_"a[3]"_"a[4]"_"a[5]"_"a[6]}' | sh
ls -1 *.SAC | awk '{split($1,a,".");print "mv "$1,a[7]"."a[8]"."a[9]"."a[10]}' | sh
rm *.10.?H?
rm SAC_*_10*
