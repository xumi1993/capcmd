#!/bin/bash
ddir=$1
ls -1 $ddir/*.[zrt] $ddir/*.sac $ddir/*.SAC $ddir/*.HN? $ddir/*.BH? | awk '{print "r "$1,"\nm cho.sm",$1}END{print "q"}' | sac

#rm cho.sm
