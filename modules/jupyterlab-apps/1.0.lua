help([[jupyterlab-apps is a collection of modules that make applications available in JupyterLab]])
depends_on("code-server/4.101")
depends_on("libreqda/1")
depends_on("rstudio-server")
depends_on("ipython-kernel")

local posix = require "posix"

local cc_cluster = os.getenv("CC_CLUSTER")
local slurm_tmpdir = os.getenv("SLURM_TMPDIR") or nil
local slurm_job_id = os.getenv("SLURM_JOB_ID") or nil
if slurm_tmpdir and slurm_job_id then
	setenv('JUPYTER_APP_LAUNCHER_PATH', slurm_tmpdir)
	if posix.stat(pathJoin("/cvmfs/soft.computecanada.ca/config/jupyterhub_node/v6/share/jupyter/jupyter_app_launcher/", cc_cluster),"type") == 'directory' then
		setenv('JUPYTER_APP_LAUNCHER_TEMPLATES_PATH', '/cvmfs/soft.computecanada.ca/config/jupyterhub_node/v6/share/jupyter/jupyter_app_launcher/' .. cc_cluster)
	else
		setenv('JUPYTER_APP_LAUNCHER_TEMPLATES_PATH', '/cvmfs/soft.computecanada.ca/config/jupyterhub_node/v6/share/jupyter/jupyter_app_launcher/')
	end
	execute {cmd="/cvmfs/soft.computecanada.ca/config/jupyterhub_node/scripts/jp_app_launcher_templater.py", modeA={"load"}}
end
