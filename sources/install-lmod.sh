#!/bin/sh
mkdir /tmp/build-lmod
cd /tmp/build-lmod
CUSTOM=/cvmfs/soft.computecanada.ca/custom
LUA=/cvmfs/soft.computecanada.ca/custom/software/lua
TCL=/cvmfs/soft.computecanada.ca/custom/software/tcl
tar xf $CUSTOM/sources/Lmod-8.7.60.tar.gz
cd Lmod-8.7.60
export CPATH=$TCL/include
export LIBRARY_PATH=$TCL/lib
export PATH=$TCL/bin:$LUA/bin:$PATH
sed -i "s@TCL_PATH=.*@TCL_PATH=$TCL/bin/tclsh8.6/@" proj_mgmt/find_tcl_pc.sh
./configure --with-duplicatePaths=yes --with-caseIndependentSorting=yes --with-redirect=yes --with-module-root-path=/cvmfs/soft.computecanada.ca/easybuild/modules --prefix=$CUSTOM/software --with-availExtensions=no LIBS="-lm -ldl"
rm -rf $CUSTOM/software/lmod
make install
chmod -R go+rX $CUSTOM/software/lmod
cd ..
rm -rf /tmp/build-lmod


