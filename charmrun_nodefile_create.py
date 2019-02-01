# this program takes as argument $SLURM_NODELIST
# and creates nodefile.dat which can then be used by charmrun
# charmrun is used to launch verbs version of NAMD
# see https://docs.computecanada.ca/wiki/NAMD
import sys
a=sys.argv[1]
nodefile=open("nodefile.dat","w")

cluster=a[0:3]
for st in a.lstrip(cluster+"[").rstrip("]").split(","):
    d=st.split("-")
    start=int(d[0])
    finish=start
    if(len(d)==2):
        finish=int(d[1])

    for i in range(start,finish+1):
        nodefile.write("host "+cluster+str(i)+"\n")

nodefile.close()

