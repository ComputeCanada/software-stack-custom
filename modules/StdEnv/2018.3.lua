add_property(   "lmod", "sticky")

local root = "/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09"

require("os")
load("nixpkgs/16.09")
load("imkl/2018.3.222")
local cpu_vendor_id = os.getenv("RSNT_CPU_VENDOR_ID")
if cpu_vendor_id == "amd" then
	load("gcc/7.3.0")
else
	load("intel/2018.3")
end
load("openmpi/3.1.2")
