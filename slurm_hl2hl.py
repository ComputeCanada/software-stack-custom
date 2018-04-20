#!/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/bin/python

# this program takes as argument $SLURM_NODELIST
# and creates nodefile.dat which can then be used by charmrun
# charmrun is used to launch verbs version of NAMD
# see https://docs.computecanada.ca/wiki/NAMD

import sys
import os
import socket

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
    HOSTS=os.environ['SLURM_NODELIST']
    if not os.environ.has_key('SLURM_NTASKS_PER_NODE'): return False
    ntasks_per_node = int(os.environ['SLURM_NTASKS_PER_NODE'])
    if not os.environ.has_key('SLURM_CPUS_PER_TASK'): 
        cpus_per_task = 1
    else:
        cpus_per_task = int(os.environ['SLURM_CPUS_PER_TASK'])

    CORES_PER_NODE=ntasks_per_node * cpus_per_task

    prefix=HOSTS[0:3]
    for st in HOSTS.lstrip(prefix+"[").rstrip("]").split(","):
        d=st.split("-")
        start=int(d[0])
        finish=start
        if(len(d)==2):
            finish=int(d[1])
	
	if d[0][0] == '0':
		padding=True

        for i in range(start,finish+1):
            if padding:
                p_oHosts[prefix + str(i).zfill(len(d[0]))] = CORES_PER_NODE
            else:
                p_oHosts[prefix + str(i)] = CORES_PER_NODE

    return True

if __name__ == "__main__":
    try:
        if len(sys.argv) != 3 or sys.argv[1] != "--format":
            print "Usage : ", sys.argv[0], " --format (ANSYS-CFX | ANSYS-FLUENT | HP-MPI | PDSH | GAUSSIAN | CHARM | STAR-CCM+ | MPIHOSTLIST)"
            sys.exit(EXIT_CODE_INVALID_USAGE)

        hosts = {}
        if not extract_info(hosts):
            print "Could not extract hosts information from SLURM environment variables."
            sys.exit(EXIT_CODE_EXTRACT_ERROR)

        fmt=sys.argv[2]
        if fmt == "ANSYS-CFX":
            master_host = socket.gethostname()
            nodes = []
            for hostname, cores in hosts.iteritems():
                # the master host must absolutely use the same as the hostname returned by "hostname"
                if hostname in master_host:
                    hostname = master_host
                nodes.append(hostname + "*" + str(cores))
            print ",".join(nodes)
        elif fmt == "ANSYS-FLUENT" or fmt == "MPIHOSTLIST":
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

