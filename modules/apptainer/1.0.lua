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

local root = "/opt/software/apptainer-1.0"

-- for symlinked /usr/sbin/unsquashfs
prepend_path("PATH", "/cvmfs/soft.computecanada.ca/custom/software/apptainer/bin")
prepend_path("PATH", pathJoin(root, "bin"))
local slurm_tmpdir = os.getenv("SLURM_TMPDIR") or nil
local scratch = os.getenv("SCRATCH") or "/tmp"
if slurm_tmpdir then
	setenv("APPTAINER_TMPDIR",slurm_tmpdir)
else
	setenv("APPTAINER_TMPDIR",scratch)
end
load("apptainer/1.1")
