#!/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/bin/python

# this program takes as argument $SLURM_NODELIST
# and creates nodefile.dat which can then be used by charmrun
# charmrun is used to launch verbs version of NAMD
# see https://docs.computecanada.ca/wiki/NAMD

import sys
import os

EXIT_CODE_UNKNOWN_ERROR = 1
EXIT_CODE_INVALID_USAGE = 2
EXIT_CODE_EXTRACT_ERROR = 3

"""
 Extract a hostname list associated with their number of cores
 from the SLURM_NODELIST environment variable
"""
def extract_info(p_oHosts):
    assert(type(p_oHosts) == type({}) and len(p_oHosts) == 0)
    if not os.environ.has_key('SLURM_NODELIST'): return False
    if not os.environ.has_key('SLURM_NTASKS_PER_NODE'): return False
    if not os.environ.has_key('SLURM_CPUS_PER_TASK'): return False

    HOSTS=os.environ['SLURM_NODELIST']
    CORES_PER_NODE=int(os.environ['SLURM_NTASKS_PER_NODE'])*int(os.environ['SLURM_CPUS_PER_TASK'])

    prefix=HOSTS[0:3]
    for st in HOSTS.lstrip(prefix+"[").rstrip("]").split(","):
        d=st.split("-")
        start=int(d[0])
        finish=start
        if(len(d)==2):
            finish=int(d[1])

        for i in range(start,finish+1):
            p_oHosts[prefix + str(i)] = CORES_PER_NODE

    return True

if __name__ == "__main__":
    try:
        if len(sys.argv) != 3 or sys.argv[1] != "--format":
            print "Usage : ", sys.argv[0], " --format (ANSYS-CFX | ANSYS-FLUENT | HP-MPI | PDSH | GAUSSIAN | CHARM | STAR-CCM+)"
            sys.exit(EXIT_CODE_INVALID_USAGE)

        hosts = {}
        if not extract_info(hosts):
            print "Could not extract hosts information from MOAB_TASKMAP."
            sys.exit(EXIT_CODE_EXTRACT_ERROR)

        fmt=sys.argv[2]
        if fmt == "ANSYS-CFX":
            nodes = []
            for hostname, cores in hosts.iteritems():
                nodes.append(hostname + "*" + str(cores))
            print ",".join(nodes)
        elif fmt == "ANSYS-FLUENT":
            for hostname, cores in hosts.iteritems():
                print "\n".join([hostname] * int(cores))
        elif fmt == "HP-MPI" or fmt == "STAR-CCM+":
            for hostname, cores in hosts.iteritems():
                print hostname + ":" + str(cores)
        elif fmt == "PDSH":
            print ",".join(hosts.iterkeys())
        elif fmt == "GAUSSIAN":
            print " ".join(hosts.iterkeys())
        elif fmt == "CHARM":
            for hostname, cores in hosts.iteritems():
                print "host " + hostname
    except:
        sys.exit(EXIT_CODE_UNKNOWN_ERROR)

