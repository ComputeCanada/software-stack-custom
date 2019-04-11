add_property(   "lmod", "sticky")

require("os")
require("posix")

-- we need posix.setenv to allow the defaults to apply when loading openmpi
posix.setenv("EBVERSIONSTDENV","2016.4")
setenv("EBVERSIONSTDENV",os.getenv("EBVERSIONSTDENV"))

load("nixpkgs/16.09")
load("imkl/11.3.4.258")
load("intel/2016.4")
load("openmpi")
