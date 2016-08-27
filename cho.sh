#!/bin/bash

ls -1 *.[zrt] *.sac *.SAC *.HN? *.BH? | awk '{print "r "$1,"\nm cho.sm",$1}END{print "q"}' | sac

#rm cho.sm
