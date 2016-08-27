#!/usr/bin/env python
import os
import sys

ddir=sys.argv[1]
#ps=$ddir/rot_dir/depth.ps

result = os.popen("cat %s/rot_dir/*.out|grep ERR |awk '{gsub($2,\"\"); print $0 }'|awk '{gsub(\"_\",\" \");print $4,$6,$7,$8,$10,$12*1e5}' |sort -n" % (ddir)).readlines()

depth = [int(dep.split()[0]) for dep in result]
fm = [[int(dep.split()[1]), int(dep.split()[2]), int(dep.split()[3]), float(dep.split()[4])] for dep in result]
rms = [float(dep.split()[5]) for dep in result]

dep_range = [min(depth)-1, max(depth)+1]
rms_range = [min(rms)*0.93, max(rms)*1.10]

with open("meca.tmp", "w+") as f:
    for i in range(len(depth)):
        f.write("%d %f 0 %d %d %d %f 0 0\n" % (depth[i],rms[i],fm[i][0],fm[i][1],fm[i][2],fm[i][3]))

with open("gmt.sh", "w+") as f:
    f.write("ps=%s\n" % (os.path.join(ddir,"rot_dir","depth.ps")))
    f.write("gmt psbasemap -R%d/%d/%d/%d -JX3i/4i -Bxa1 -BWSne -K > $ps\n" % (dep_range[0],dep_range[1],rms_range[0],rms_range[1]))
    f.write("gmt psmeca -R -J -O -K -Sa0.7 -G0 meca.tmp >> $ps\n")
    f.write("rm meca.tmp\n")

os.system("sh gmt.sh")
#os.system()
