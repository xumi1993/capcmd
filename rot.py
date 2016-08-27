#!/usr/bin/env python
import sys
import os
from os.path import join
import glob
import shutil
import subprocess

ddir = sys.argv[1]
in_dir = "%s/ground_vel" % ddir
out_dir = "%s/rot_dir" % ddir
if not os.path.exists(out_dir):
    os.makedirs(out_dir)
stations = []
isNE = 0
os.putenv("SAC_DISPLAY_COPYRIGHT", '0')
p = subprocess.Popen(['sac'], stdin=subprocess.PIPE)
s = ""
for sac in glob.glob(in_dir+'/*.?HZ'):
    sacname = os.path.basename(sac)
    netname = sacname.split('.')[0]
    staname = sacname.split('.')[1]
    location = sacname.split('.')[2]
    print(join(out_dir,netname+'.'+staname+'.'+location+'.r'))
    try:
        fl_1 = glob.glob(in_dir+'/'+netname+'.'+staname+'.'+location+'.?H1')[0]
        fl_2 = glob.glob(in_dir+'/'+netname+'.'+staname+'.'+location+'.?H2')[0]
    except:
        try:
            fl_1 = glob.glob(in_dir+'/'+netname+'.'+staname+'.'+location+'.?HE')[0]
            fl_2 = glob.glob(in_dir+'/'+netname+'.'+staname+'.'+location+'.?HN')[0]
            isNE = 1
        except:
            continue
    cmd = "saclst b e cmpaz cmpinc f %s" % (fl_1)
    junk, b1, e1, cmpaz1, cmpinc1 = os.popen(cmd).read().split()
    b1 = float(b1)
    e1 = float(e1)
    cmpaz1 = round(float(cmpaz1),1)
    cmpinc1 = round(float(cmpinc1),1)
    cmd = "saclst b e cmpaz cmpinc f %s" % (fl_2)
    junk, b2, e2, cmpaz2, cmpinc2 = os.popen(cmd).read().split()
    b2 = float(b2)
    e2 = float(e2)
    cmpaz2 = round(float(cmpaz2),1)
    cmpinc2 = round(float(cmpinc2),1)
    cmd = "saclst b e f %s" % (sac)
    junk, b3, e3 = os.popen(cmd).read().split()
    b3 = float(b3)
    e3 = float(e3)
    # correct cmpaz when is need
    diff_az = round(cmpaz1 - cmpaz2, 1)
    print(diff_az)
    if not (abs(diff_az) == 90 or abs(diff_az) == 270):
        if abs(diff_az) > 180:
            if diff_az > 0:
                corr = diff_az - 270
            else:
                corr = diff_az + 270
        else:
            if diff_az > 0:
                corr = diff_az - 90
            else:
                corr = diff_az + 90
        if isNE:
            s += "r %s\nch cmpaz %d\nwh\n" % (fl_1, 90)
            s += "r %s\nch cmpaz %d\nwh\n" % (fl_2, 0)
        else:
            cmpaz1 = round(cmpaz1 - corr, 1)
            if cmpaz1 < 0:
                cmpaz1 += 360
            if cmpaz1 >= 360:
                cmpaz1 -= 360
            s += "r %s\nch cmpaz %8.2f\nwh\n" % (fl_1, cmpaz1)
            s += "r %s\nch cmpaz %8.2f\nwh\n" % (fl_2, cmpaz2)
    # Correct cmpinc
    if not (cmpinc1 == 90 or cmpinc2 == 90):
        s += "r %s %s\nch cmpinc 90\nwh\n" % (fl_1, fl_2)

    if b2>b1 and b2>b3:
        b = b2
    elif b3>b1 and b3>b2:
        b = b3
    else:
        b = b1
    if e2<e1 and e2<e3:
        e = e2
    elif e3<e1 and e3<e2:
        e = e3
    else:
        e = e1
    b += 0.1
    e -= 0.1
    s += "cut off\ncut %f %f\n" % (b, e)
    s += "r %s %s\n" % (fl_1, fl_2)
    s += "rot to gcp\n"
    s += "w %s %s\n" % (join(out_dir,netname+'.'+staname+'.'+location+'.r'), join(out_dir,netname+'.'+staname+'.'+location+'.t'))
    s += "cut off\n"
    shutil.copy(sac, join(out_dir,netname+'.'+staname+'.'+location+'.z'))
s += "q\n"
p.communicate(s.encode())
 
