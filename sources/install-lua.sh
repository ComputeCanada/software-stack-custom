#!/bin/sh
mkdir /tmp/build-lua
cd /tmp/build-lua
tar xf /cvmfs/soft.computecanada.ca/custom/sources/lua-5.1.4.9.tar.bz2
cd lua-5.1.4.9
patch -p1 < /cvmfs/soft.computecanada.ca/custom/sources/luaposix-disable-rt-crypt.patch
./configure --prefix=/cvmfs/soft.computecanada.ca/custom/software/lua --with-static=yes
rm -rf /cvmfs/soft.computecanada.ca/custom/software/lua
make install
cd ..
rm -rf /tmp/build-lua
