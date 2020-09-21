add_property(   "lmod", "sticky")

require("os")
load("CCconfig")
local arch = "avx"
pushenv("RSNT_ARCH", arch)

load("gentoo/2020")

prepend_path("MODULEPATH", "/cvmfs/soft.computecanada.ca/easybuild/modules/2020/Core")
prepend_path("MODULEPATH", pathJoin("/cvmfs/soft.computecanada.ca/easybuild/modules/2020", arch, "Core"))

local user = os.getenv("USER","unknown")
local home = os.getenv("HOME",pathJoin("/home",user))
if user ~= "ebuser" then
    prepend_path("MODULEPATH", pathJoin(home, ".local/easybuild/modules/2020/Core"))
    prepend_path("MODULEPATH", pathJoin(home, ".local/easybuild/modules/2020", arch, "Core"))
end

load("imkl/2020.1.217")
load("intel/2020.1.217")
load("openmpi/4.0.3")
