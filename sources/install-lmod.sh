#!/bin/sh
mkdir /tmp/build-lmod
cd /tmp/build-lmod
CUSTOM=/cvmfs/soft.computecanada.ca/custom
LUA=/cvmfs/soft.computecanada.ca/custom/software/lua
TCL=/cvmfs/soft.computecanada.ca/custom/software/tcl
tar xf $CUSTOM/sources/Lmod-8.3.8.tar.gz
cd Lmod-8.3.8
export CPATH=$TCL/include
export LIBRARY_PATH=$TCL/lib
export PATH=$TCL/bin:$LUA/bin:$PATH
./configure --with-duplicatePaths=yes --with-caseIndependentSorting=yes --with-redirect=yes --with-module-root-path=/cvmfs/soft.computecanada.ca/easybuild/modules --prefix=$CUSTOM/software LIBS="-lm -ldl"
rm -rf $CUSTOM/software/lmod
make install
cd ..
rm -rf /tmp/build-lmod


