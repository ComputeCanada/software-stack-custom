add_property(   "lmod", "sticky")

require("os")
require("string")
load("CCconfig")
load("gentoo/2020")

local has_h100 = string.match((os.getenv("RSNT_GPU_TYPES") or "") .. ",", "H100,")
if (has_h100) then
	pushenv("LMOD_ADMIN_FILE", "/cvmfs/soft.computecanada.ca/config/lmod/admin_2025.list")
end

load("imkl")
local cpu_vendor_id = os.getenv("RSNT_CPU_VENDOR_ID")
local arch = os.getenv("RSNT_ARCH")
if cpu_vendor_id == "amd" and arch == "avx512" then
	load("gcc")
else
	load("intel")
end
load("openmpi")
if cpu_vendor_id == "amd" then
	load("flexiblas")
	load("blis")
	setenv("FLEXIBLAS", "blis")
end
