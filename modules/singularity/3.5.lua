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

local root = "/opt/software/singularity-3.5"

prepend_path("PATH", pathJoin(root, "bin"))
local slurm_tmpdir = os.getenv("SLURM_TMPDIR") or nil
local scratch = os.getenv("SCRATCH") or "/tmp"
if slurm_tmpdir then
	setenv("SINGULARITY_TMPDIR",slurm_tmpdir)
else
	setenv("SINGULARITY_TMPDIR",scratch)
end

local posix = require "posix"
local user = os.getenv("USER") or nil
if user then
	local home = os.getenv("HOME") or pathJoin("/home", user)
	local default_singularity_cachedir = pathJoin(home, ".singularity")
	local default_singularity_cachedir_type = posix.stat(default_singularity_cachedir, "type") or nil
	if default_singularity_cachedir_type == "directory" or default_singularity_cachedir_type == "link"  then
		setenv("SINGULARITY_CACHEDIR", default_singularity_cachedir)
	else
		local singularity_cachedir = pathJoin(scratch, ".singularity")
		local singularity_cachedir_type = posix.stat(singularity_cachedir, "type") or nil
		if singularity_cachedir_type == "directory" or singularity_cachedir_type == "link" then
			setenv("SINGULARITY_CACHEDIR", singularity_cachedir)
		end
	end
end

