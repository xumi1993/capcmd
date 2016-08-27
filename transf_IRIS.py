#!/usr/bin/env python

# Import module
import os
import sys
import glob
import subprocess

ddir = sys.argv[1] # Get command line parameter
if not os.path.exists("%s/ground_vel" % ddir): 
    os.makedirs("%s/ground_vel" % ddir) # Make a new directory to save new SAC files
dt = 0.5 # Set sampling interval to resample
fl_z = glob.glob("%s/*.?H?" % ddir) # Match each eventsa
stations = [[os.path.basename(fl).split('.')[0], os.path.basename(fl).split('.')[1], os.path.basename(fl).split('.')[-2]] for fl in fl_z] # Get station infomation (network, station, location)
os.putenv("SAC_DISPLAY_COPYRIGHT", '0')
p = subprocess.Popen(['sac'], stdin=subprocess.PIPE)
s = '' # Open SAC macro
for sta in stations:
    for comp in glob.glob("%s/%s.%s.%s.?H?" % (ddir, sta[0], sta[1], sta[2])):
        sacname = os.path.basename(comp) # Get each SAC file in single station
        cname = comp.split('.')[-1] # Get component name
        resfile = glob.glob("%s/SAC_PZs_%s_%s_%s_%s" % (ddir, sta[0], sta[1], cname, sta[2]))[0] # Match instrumental response file
        s += "r %s\n" % comp # read SAC file
        s += "rmean\nrtr\n"
        s += "transfer FROM POLEZERO SUBTYPE %s TO VEL freq 0.004 0.005 10 12\n" % resfile # Remove instrumental response with a filter after deconvolution
        s += "rtr\nrmean\n"
        s += "mul 100\n" # Convert the unit of amplitude to cm 
#        s += "int\n"
#        s += "interp delta 0.5\n" # Resample
        s += "w %s/ground_vel/%s\n" %(ddir, sacname) # write SAC file
s += "q\n"
p.communicate(s.encode()) # execute SAC macro
