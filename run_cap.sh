#!/bin/sh

ddir=$1
green=/data/GREEN_LIB
#green=
model=premATTYT
#model=NEPALnew
mag=5.4
R=0/360/0/90/-180/180
#R=93/93/69/69/82/82
#R=290/290/18/18/98/98
D=2/1/0.5
P=0.002/20/k
I=10/0.2
S=15/20/0
C=0.02/0.08/0.01/0.04
T=100/200
Z=weight.dat
N=0


for dep in {10..10}
do
cap_3.pl -D$D -T$T -G$green  -O -P$P -H0.5 -L3. -M${model}_${dep}/${mag} -W1 -R$R  -S$S -C$C -I$I -Z$Z -A1/0/0 $ddir/rot_dir

cd $ddir/rot_dir
ps2pdf ${model}_${dep}.ps
rm $ddir/rot_dir/${model}_*.[0-9]
# open $ddir/data/${model}_*.ps
#cp ${model}_${dep}.out ${model}_${dep}_Hz.out

#cp  ${model}_${dep}.pdf  ${model}_${dep}_${Z}.pdf
#evince ${model}_${dep}.pdf

cd ..

done
