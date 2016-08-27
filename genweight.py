#!/usr/bin/env python
import sys
import os
import getopt
import seispy
import glob
import obspy

is2dc = 0
argv = sys.argv[1:]
for opt in sys.argv[1:]:
    if os.path.isdir(opt):
        ddir = os.path.join(opt,"rot_dir")
    elif opt == "-d":
        is2dc = 1
    elif opt[0:2] == "-t":
        value = opt[2:]
        thr = float(value.split('/')[0])
        thz = float(value.split('/')[1])
    else:
        print("\n    Invalid Arguments.\n")
        sys.exit(1)

f = open(os.path.join(ddir,"weight.tmp"), 'w+')
for datz in glob.glob(os.path.join(ddir,"*.z")):
    datr = datz[0:-1]+"r"
    datt = datz[0:-1]+"t"
    trr = obspy.read(datr)[0]
    trz = obspy.read(datz)[0]
    dt = trr.stats.delta
    btime = trr.stats.sac.b
    parr = trr.stats.sac.t6
    gcarc = trr.stats.sac.gcarc
    trr.filter('bandpass',freqmin=0.01, freqmax=0.1)
    snrr = seispy.geo.snr(trr.data[int((parr-btime)/dt):int((parr+100-btime)/dt)],
                          trr.data[int((parr-100-btime)/dt):int((parr-btime)/dt)])
    trz.filter('bandpass',freqmin=0.01, freqmax=0.1)
    snrz = seispy.geo.snr(trz.data[int((parr-btime)/dt):int((parr+100-btime)/dt)],
                          trz.data[int((parr-100-btime)/dt):int((parr-btime)/dt)])
    if snrr >= thr and snrz >= thz:
        print(trr,snrr,snrz)
        if is2dc:
            f.write("%s %f %3.1f 1 0 0 0 1 0 0 0\n" % (os.path.basename(datz[0:-2]),gcarc,gcarc))
        else:
            f.write("%s %f %3.1f 1 1 1 1 1 0 0 0\n" % (os.path.basename(datz[0:-2]),gcarc,gcarc))
f.close()
os.system("cat %s/weight.tmp|sort -n --key=3 > %s/weight.dat" % (ddir,ddir))
os.system("rm %s/weight.tmp" % (ddir))
