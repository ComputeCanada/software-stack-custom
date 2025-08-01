add_property(   "lmod", "sticky")

require("os")
require("string")
load("CCconfig")
load("gentoo/2020")

local has_h100 = string.match((os.getenv("RSNT_GPU_TYPES") or "") .. ",", "H100,")
if (has_h100) then
	pushenv("LMOD_ADMIN_FILE", "/cvmfs/soft.computecanada.ca/config/lmod/admin_2025.list")
elseif (mode() == "spider") then
	-- set by gentoo/2020 module
	local arch = os.getenv("RSNT_ARCH")
	prepend_path("MODULEPATH", "/cvmfs/soft.computecanada.ca/easybuild/modules/2020/Core")
	prepend_path("MODULEPATH", pathJoin("/cvmfs/soft.computecanada.ca/easybuild/modules/2020", arch, "Core"))
	local user = os.getenv("USER","unknown")
	local home = os.getenv("HOME",pathJoin("/home",user))
	if user ~= "ebuser" then
		prepend_path("MODULEPATH", pathJoin(home, ".local/easybuild/modules/2020/Core"))
		prepend_path("MODULEPATH", pathJoin(home, ".local/easybuild/modules/2020", arch, "Core"))
	end
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
