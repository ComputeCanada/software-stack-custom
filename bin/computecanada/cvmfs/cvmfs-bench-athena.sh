#!/bin/bash

# Set up an ATLAS Athena software release, uses atlas.cern.ch repo

export ATLAS_LOCAL_ROOT=/cvmfs/atlas.cern.ch/repo
export ATLAS_LOCAL_ROOT_BASE=${ATLAS_LOCAL_ROOT}/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh > /dev/null 2>&1
source ${ATLAS_LOCAL_ROOT_BASE}/x86_64/AtlasSetup/current/AtlasSetup/scripts/asetup.sh 19.0.0 > /dev/null 2>&1
/cvmfs/atlas.cern.ch/repo/sw/software/x86_64-slc6-gcc47-opt/19.0.0/AtlasCore/19.0.0/InstallArea/share/bin/athena.py AthExHelloWorld/HelloWorldOptions.py > /dev/null 2>&1

