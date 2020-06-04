#!/bin/sh
mkdir /tmp/build-tcl
cd /tmp/build-tcl
tar xf /cvmfs/soft.computecanada.ca/custom/sources/tcl8.6.10-src.tar.gz
cd tcl8.6.10/unix
./configure --prefix=/cvmfs/soft.computecanada.ca/custom/software/tcl --disable-shared --disable-threads
rm -rf /cvmfs/soft.computecanada.ca/custom/software/tcl
make install-binaries install-libraries install-headers
ln -s tclsh8.6 /cvmfs/soft.computecanada.ca/custom/software/tcl/bin/tclsh
cd ..
rm -rf /tmp/build-tcl

