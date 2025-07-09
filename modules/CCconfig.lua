require("os")
local posix = require("posix")
local stat = posix.stat

if not os.getenv("RSNT_NO_CCCONFIG") then
--------------------------------------------------------------------------------------------------------
-- Configuration related to Slurm
--------------------------------------------------------------------------------------------------------
-- if SQUEUE_FORMAT is not already defined, define it
if not os.getenv("SQUEUE_FORMAT") then
	setenv("SQUEUE_FORMAT","%.15i %.8u %.12a %.14j %.3t %.10L %.5D %.4C %.10b %.7m %N (%r) ")
end

-- if SQUEUE_SORT is not already defined, define it
if not os.getenv("SQUEUE_SORT") then
	setenv("SQUEUE_SORT", "-t,e,S")
end

-- if SACCT_FORMAT is not already defined, define it
if not os.getenv("SACCT_FORMAT") then
	setenv("SACCT_FORMAT","Account,User,JobID,Start,End,AllocCPUS,Elapsed,AllocTRES%30,CPUTime,AveRSS,MaxRSS,MaxRSSTask,MaxRSSNode,NodeList,ExitCode,State%20")
end

-- if SLURM_TMPDIR is set, define LOCAL_SCRATCH to use it unless LOCAL_SCRATCH was already set or does not exist
if os.getenv("SLURM_TMPDIR") and (not os.getenv("LOCAL_SCRATCH") or stat(os.getenv("LOCAL_SCRATCH"), "type") ~= "directory") then
       setenv("LOCAL_SCRATCH", os.getenv("SLURM_TMPDIR"))
end


--------------------------------------------------------------------------------------------------------
-- Other Compute Canada configuration
--------------------------------------------------------------------------------------------------------
-- alias the "quota" command to the "diskusage_report" script
if not os.getenv("RSNT_NO_QUOTA_ALIAS") then
	set_alias("quota", "diskusage_report")
end 

if not os.getenv("RSNT_NO_LS_COLORS") then
	-- do not colour certain attributes of ls
	-- this avoids inode lookups for plain "ls"
	append_path("LS_COLORS", "su=00:sg=00:ca=00:ow=00:st=00:tw=00:ex=00:or=00:")
end

--------------------------------------------------------------------------------------------------------
-- Compute Canada configuration for filesystem layout
--------------------------------------------------------------------------------------------------------
local user = os.getenv("USER","unknown")
local home = os.getenv("HOME",pathJoin("/home",user))

-- define PROJECT and SCRATCH environments

local def_scratch_dir = pathJoin("/scratch",user)
local def_project_link = pathJoin(home,"project")
local project_dir = nil

-- if project_dir was not found based on SLURM_JOB_ACCOUNT, test the default project 
project_dir = def_project_link
if not project_dir and stat(def_project_link,"type") == "link" then
	-- find the directory this link points to
	project_dir = subprocess("readlink " .. def_project_link)
end
if project_dir and (stat(project_dir,"type") == "link" or stat(project_dir, "type") == "dir") then
	-- if PROJECT is not defined, or if it was defined by us previously (i.e. in the login environment), define it
	if not os.getenv("PROJECT") or os.getenv("PROJECT") == os.getenv("CC_PROJECT") then
		setenv("PROJECT", project_dir)
	end
	-- define CC_PROJECT nevertheless
	setenv("CC_PROJECT", project_dir)
end
-- do not overwrite the environment variable if it already exists
if not os.getenv("SCRATCH") then
--	if stat(def_scratch_dir,"type") == "directory" then
		setenv("SCRATCH", def_scratch_dir)
--	end
end

prepend_path("PATH", "/cvmfs/soft.computecanada.ca/custom/bin/computecanada")

--------------------------------------------------------------------------------------------------------
-- Cluster to GPU mapping
--------------------------------------------------------------------------------------------------------
local cluster_to_gpus = {
	[ "cedar"     ] = "P100,V100",
	[ "graham"    ] = "V100,T4,A100,A5000",
	[ "niagara"   ] = "",
	[ "beluga"    ] = "V100",
	[ "narval"    ] = "A100",
	[ "rorqual"   ] = "H100",
	[ "nibi"      ] = "H100",
	[ "fir"	      ] = "H100",
	[ "trillium"  ] = "H100",
	[ "tamia"     ] = "H100",
	[ "killarney" ] = "H100",
	[ "vulcan"    ] = "H100",
}

local gpu_types = os.getenv("RSNT_GPU_TYPES") or ""
if mode() == "load" and (not gpu_types or gpu_types == "") then
	local cc_cluster = os.getenv("CC_CLUSTER") or "computecanada"
	setenv("RSNT_GPU_TYPES", cluster_to_gpus[cc_cluster] or "")
end

end
