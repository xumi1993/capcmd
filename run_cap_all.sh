#!/bin/sh

ddir=$1
green=/Volumes/xumj2/GREEN_LIB
model=premATTYT
#model=NEPALnew
mag=7.3
R=0/360/0/90/-180/180
#R=93/93/69/69/82/82
#R=290/290/18/18/98/98
D=1/0/0
P=8e-5/40/k
I=10/0.2
S=15/20/0
C=0.01/0.08/0.010/0.060
T=100/100
Z=weight.dat 
N=0

echo "Remove response..."
./transf_IRIS.py $ddir
echo "Rotate components to T-R-Z"
./rot.py $ddir
echo "Set time mark"
./pick_t2t4.sh $ddir
echo "Create weight file"
./genweight.sh $ddir

for dep in {15..15}
do
perl cap_3.pl -D$D -T$T -G$green  -O -P$P -H0.5 -L10. -M${model}_${dep}/${mag} -W1 -R$R  -S$S -C$C -I$I -Z$Z -A1/0/0 $ddir/data

#cd ./data
#ps2pdf ${model}_${dep}.ps
rm $ddir/data/${model}_*.[0-9]
open $ddir/data/${model}_*.ps
#cp ${model}_${dep}.out ${model}_${dep}_Hz.out

#cp  ${model}_${dep}.pdf  ${model}_${dep}_${Z}.pdf
#evince ${model}_${dep}.pdf

#cd ..

done
