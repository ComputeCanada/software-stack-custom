add_property(   "lmod", "sticky")

local root = "/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09"

require("os")
--if os.getenv("LMOD_SYSTEM_NAME") == "cedar" then
	load("nixpkgs/16.09")
	-- ensure that these paths are ahead of Nix's. 
	prepend_path("PATH","/opt/software/slurm/bin")
	prepend_path("PATH","/opt/puppetlabs/puppet/bin")
	prepend_path("PATH","/opt/software/bin")
	load("intel")
	load("imkl")
	load("openmpi")
--else
--end
