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

local root = "/opt/software/singularity-3.8"

-- for symlinked unsquashfs
prepend_path("PATH", "/cvmfs/soft.computecanada.ca/custom/software/apptainer/bin")
prepend_path("PATH", pathJoin(root, "bin"))
local slurm_tmpdir = os.getenv("SLURM_TMPDIR") or nil
local scratch = os.getenv("SCRATCH") or "/tmp"
if slurm_tmpdir then
	setenv("SINGULARITY_TMPDIR",slurm_tmpdir)
else
	setenv("SINGULARITY_TMPDIR",scratch)
end

