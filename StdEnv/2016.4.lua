add_property(   "lmod", "sticky")

local root = "/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09"

require("os")
--if os.getenv("LMOD_SYSTEM_NAME") == "cedar" then
	load("nixpkgs/16.09")
	load("intel")
	load("imkl")
	load("openmpi")
--else
--end
