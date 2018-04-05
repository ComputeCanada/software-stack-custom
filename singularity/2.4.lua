help([[Singularity is an application containerization solution for High-Performance Computing (HPC). The goal
of Singularity is to allow for "mobility of computing": an application containerized on one Linux system should 
be able to run on another system, as it is, and without the need to reconcile software dependencies and Linux 
version differences between the source and target systems. 
- Website: http://singularity.lbl.gov/ 
- CC-Wiki: Singularity ]])
whatis([[Description: Singularity is an application containerization solution for High-Performance Computing (HPC). The goal
of Singularity is to allow for "mobility of computing": an application containerized on one Linux system should 
be able to run on another system, as it is, and without the need to reconcile software dependencies and Linux 
version differences between the source and target systems. 
- Website: http://singularity.lbl.gov/ 
- CC-Wiki: Singularity ]])

local root = "/opt/software/singularity-2.4"

prepend_path("PATH", pathJoin(root, "bin"))

