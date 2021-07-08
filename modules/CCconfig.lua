require("os")

if not os.getenv("RSNT_NO_CCCONFIG") then
--------------------------------------------------------------------------------------------------------
-- Configuration related to Slurm
--------------------------------------------------------------------------------------------------------
-- if SQUEUE_FORMAT is not already defined, define it
if not os.getenv("SQUEUE_FORMAT") then
	setenv("SQUEUE_FORMAT","%.15i %.8u %.16a %.14j %.3t %.10L %.5D %.4C %.10b %.7m %N (%r) ")
end

-- if SQUEUE_SORT is not already defined, define it
if not os.getenv("SQUEUE_SORT") then
	setenv("SQUEUE_SORT", "-t,e,S")
end

-- if SACCT_FORMAT is not already defined, define it
if not os.getenv("SACCT_FORMAT") then
	setenv("SACCT_FORMAT","Account,User,JobID,Start,End,AllocCPUS,Elapsed,AllocTRES%30,CPUTime,AveRSS,MaxRSS,MaxRSSTask,MaxRSSNode,NodeList,ExitCode,State%20")
end

-- if SLURM_TMPDIR is set, define TMPDIR to use it unless TMPDIR was already set to something different than /tmp
if os.getenv("SLURM_TMPDIR") and (not os.getenv("TMPDIR") or os.getenv("TMPDIR") == "/tmp") then
	setenv("TMPDIR", os.getenv("SLURM_TMPDIR"))
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
	append_path("LS_COLORS", "su=00:sg=00:ca=00:ow=00:st=00:tw=00:ex=00:")
end

--------------------------------------------------------------------------------------------------------
-- Compute Canada configuration for filesystem layout
--------------------------------------------------------------------------------------------------------
local user = os.getenv("USER","unknown")
local home = os.getenv("HOME",pathJoin("/home",user))

-- define PROJECT and SCRATCH environments
local posix = require("posix")
local stat = posix.stat

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

end
