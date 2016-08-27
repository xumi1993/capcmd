#!/usr/bin/python

import sys
import os
import glob

para = sys.argv[1:]
for op in para:
    if os.path.isdir(op):
        indir = os.path.join(op, 'ground_vel')
    else:
        evla = float(op.split('/')[0])
        evlo = float(op.split('/')[1])
        evdp = float(op.split('/')[2])

os.putenv("SAC_DISPLAY_COPYRIGHT", '0')
p = subprocess.Popen(['sac'], stdin=subprocess.PIPE)
s = ""
for sac in glob.glob(os.path.join(indir, "*.SAC")):
    s += "r %s\n" % (sac)
    s += "ch evla %f\n" % (evla)
    s += "ch evlo %f\n" % (evlo)
    s += "ch evdp %f\n" % (evdp)
    s += "wh\n"
s += "q\n"
p.communicate(s.encode())

