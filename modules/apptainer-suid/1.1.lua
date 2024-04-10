help([[Apptainer/Singularity is an application containerization solution for High-Performance Computing (HPC). The goal
of Apptainer is to allow for "mobility of computing": an application containerized on one Linux system should 
be able to run on another system, as it is, and without the need to reconcile software dependencies and Linux 
version differences between the source and target systems. 
- Website: https://apptainer.org
- CC-Wiki: Apptainer ]])
whatis([[Description: Apptainer/Singularity is an application containerization solution for High-Performance Computing (HPC). The goal
of Apptainer is to allow for "mobility of computing": an application containerized on one Linux system should 
be able to run on another system, as it is, and without the need to reconcile software dependencies and Linux 
version differences between the source and target systems. 
- Website: https://apptainer.org
- CC-Wiki: Apptainer ]])

local root = "/opt/software/apptainer-1.1"

prepend_path("PATH", pathJoin(root, "bin"))
-- for symlinked /usr/sbin/unsquashfs and apptainer wrapper
prepend_path("PATH", "/cvmfs/soft.computecanada.ca/custom/software/apptainer/bin")
setenv("EBROOTAPPTAINER", root)
setenv("EBVERSIONAPPTAINER", "1.1")
assert(loadfile("/cvmfs/soft.computecanada.ca/config/lmod/apptainer_custom.lua"))()
