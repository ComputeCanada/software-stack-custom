add_property(   "lmod", "sticky")

local root = "/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09"

require("os")
load("CCconfig")
load("gentoo/2020")
load("imkl/2020.1.217")
load("intel/2020.1.217")
load("openmpi/4.0.3")
