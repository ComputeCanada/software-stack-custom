add_property(   "lmod", "sticky")

local root = "/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09"

require("os")
load("nixpkgs/16.09")
load("imkl/11.3.4.258")
local cpu_vendor_id = os.getenv("RSNT_CPU_VENDOR_ID")
if cpu_vendor_id == "amd" then
	load("gcc/5.4.0")
else
	load("intel/2016.4")
end
load("openmpi/2.1.1")
