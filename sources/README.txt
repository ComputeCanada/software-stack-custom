Download URLs:
https://sourceforge.net/projects/lmod/files/lua-5.1.4.9.tar.bz2
https://sourceforge.net/projects/tcl/files/Tcl/8.6.10/tcl8.6.10-src.tar.gz
https://github.com/TACC/Lmod/archive/8.6.16.tar.gz

Singularity container made using:
sudo singularity build centos6.sif centos6.def

Install:
./singularity-install ./install-lua.sh
./singularity-install ./install-tcl.sh
./singularity-install ./install-lmod.sh
