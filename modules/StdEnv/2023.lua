add_property(   "lmod", "sticky")

require("os")
load("CCconfig")
load("gentoo/2023")

-- set by gentoo/2023 module
local arch = os.getenv("RSNT_ARCH")
if arch == "avx2" then
	newarch = "x86-64-v3"
elseif arch == "avx512" then
	newarch = "x86-64-v4"
end
-- gentoo/2023 will not load for sse3 and avx

if (mode() == "spider" and (arch == "avx2" or arch == "avx512")) then
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
	if (arch == "avx512") then
		load("aocl-blas")
		load("aocl-lapack")
		setenv("FLEXIBLAS", "aocl")
	else
		load("blis")
		setenv("FLEXIBLAS", "blis")
	end
else
	load("imkl")
end
