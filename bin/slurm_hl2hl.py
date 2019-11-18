#!/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/bin/python

# this program takes as argument $SLURM_NODELIST
# and creates nodefile.dat which can then be used by charmrun
# charmrun is used to launch verbs version of NAMD
# see https://docs.computecanada.ca/wiki/NAMD

import sys
import os
import socket
import subprocess
from collections import OrderedDict

EXIT_CODE_UNKNOWN_ERROR = 1
EXIT_CODE_INVALID_USAGE = 2
EXIT_CODE_EXTRACT_ERROR = 3

"""
 Extract a hostname list associated with their number of cores
 from the SLURM_NODELIST environment variable
"""
def extract_info(p_oHosts):
    assert(type(p_oHosts) == type(OrderedDict()) and len(p_oHosts) == 0)
    if not os.environ.has_key('SLURM_NTASKS_PER_NODE') and not os.environ.has_key('SLURM_TASKS_PER_NODE'):
        ntasks_per_node=1
    elif any(c in os.environ.get('SLURM_TASKS_PER_NODE', '') for c in [',','(x']):
        val = os.environ['SLURM_TASKS_PER_NODE']
        mylist = val.split(',')
        ntasks_per_node = []
        for e in mylist:
            if 'x' in e:
                v,m = tuple(e.replace(')','').replace('(','').split('x'))
                ntasks_per_node += [int(v)]*int(m)
            else:
                ntasks_per_node += [int(e)]
    else:
        ntasks_per_node = int(os.environ.get('SLURM_NTASKS_PER_NODE',
                                             os.environ.get('SLURM_TASKS_PER_NODE', 1)))
    if not os.environ.has_key('SLURM_CPUS_PER_TASK'):
        cpus_per_task = 1
    else:
        cpus_per_task = int(os.environ['SLURM_CPUS_PER_TASK'])


    p = subprocess.Popen(['scontrol', 'show',  'hostname'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    HOSTS, err = p.communicate()
    HOSTS = HOSTS.split('\n')

    if isinstance(ntasks_per_node,list):
        CORES_PER_NODE = [ x * cpus_per_task for x in ntasks_per_node ]
    else:
        CORES_PER_NODE = [ntasks_per_node * cpus_per_task] * len(HOSTS)

    for host,cores in zip(HOSTS,CORES_PER_NODE):
        if host:
            p_oHosts[host] = cores
    return True

if __name__ == "__main__":
    try:
        if len(sys.argv) != 3 or sys.argv[1] != "--format":
            print "Usage : ", sys.argv[0], " --format (ANSYS-CFX | ANSYS-FLUENT | HP-MPI | PDSH | GAUSSIAN | CHARM | STAR-CCM+ | MPIHOSTLIST | GNU-Parallel)"
            sys.exit(EXIT_CODE_INVALID_USAGE)

        hosts = OrderedDict()
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
        elif fmt == "GNU-Parallel":
            print ",".join(["{}/{}".format(c,h) for h,c in hosts.iteritems()])
    except:
        print("An error occured")
        sys.exit(EXIT_CODE_UNKNOWN_ERROR)
