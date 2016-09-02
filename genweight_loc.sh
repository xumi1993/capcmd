#!/bin/sh
dir=$1/rot_dir
nowdir=`pwd`
cd $dir
saclst dist az f *.z   | awk '{gsub(".z","",$1); printf "%s %f %d %s\n", $1,$2,$2+0.5,"1 1 1 1 1 0 0 0"}' | sort -n --key=3 > weight.dat
#saclst gcarc az f *.z   | awk '{gsub(".z","",$1); printf "%s %f %3.1f %s\n", $1,$2,$2,"1 1 1 1 1 0 0 0"}' | sort -n --key=3 > weight.dat
cd $nowdir
