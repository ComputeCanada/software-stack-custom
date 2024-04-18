add_property(   "lmod", "sticky")

require("os")
load("CCconfig")
load("gentoo/2023")

if (mode() == "spider") then
	-- set by gentoo/2023 module
	local arch = os.getenv("RSNT_ARCH")
	if arch == "avx512" then
		newarch = "x86-64-v4"
	else
		newarch = "x86-64-v3"
	end
	local coresubdir = "easybuild/modules/2023/x86-64-v3"
	local subdir = pathJoin("easybuild/modules/2023", newarch)
	prepend_path("MODULEPATH", pathJoin("/cvmfs/soft.computecanada.ca", coresubdir, "Core"))
	prepend_path("MODULEPATH", pathJoin("/cvmfs/soft.computecanada.ca", subdir, "Compiler/gcccore"))
	local user = os.getenv("USER","unknown")
	local home = os.getenv("HOME",pathJoin("/home",user))
	if user ~= "ebuser" then
		prepend_path("MODULEPATH", pathJoin(home, ".local", coresubdir, "Core"))
		prepend_path("MODULEPATH", pathJoin(home, ".local", subdir, "Compiler/gcccore"))
	end
end

load("gcc")
load("openmpi")
load("flexiblas")
local cpu_vendor_id = os.getenv("RSNT_CPU_VENDOR_ID")
if cpu_vendor_id == "amd" then
	load("blis")
	setenv("FLEXIBLAS", "blis")
else
	load("imkl")
end
