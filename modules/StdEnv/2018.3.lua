add_property(   "lmod", "sticky")

require("os")
require("posix")

-- we need posix.setenv to allow the defaults to apply when loading openmpi
posix.setenv("EBVERSIONSTDENV","2018.3")
setenv("EBVERSIONSTDENV",os.getenv("EBVERSIONSTDENV"))

load("nixpkgs/16.09")
load("imkl/2018.3.222")
load("intel/2018.3")
load("openmpi")
