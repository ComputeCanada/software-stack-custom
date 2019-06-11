add_property(   "lmod", "sticky")

local root = "/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09"

require("os")
prepend_path("MODULERCFILE", "/cvmfs/soft.computecanada.ca/config/lmod/modulerc_2018.3")
load("nixpkgs/16.09")
load("imkl/2018.3.222")
load("intel/2018.3")
load("openmpi")
