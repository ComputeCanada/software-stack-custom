#!/bin/bash

# Set up an ATLAS Athena software release and run a Hello World example analysis. Uses atlas.cern.ch repo.

# Set up ALRB
export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
# This should force container usage (to ensure compatibility across different host OSes).
export ALRB_containerSiteOnly=YES

# This is for an old athena release so use a sl6 container.
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh -c sl6 -r "source ${ATLAS_LOCAL_ROOT_BASE}/x86_64/AtlasSetup/current/AtlasSetup/scripts/asetup.sh 19.0.0; /cvmfs/atlas.cern.ch/repo/sw/software/x86_64-slc6-gcc47-opt/19.0.0/AtlasCore/19.0.0/InstallArea/share/bin/athena.py AthExHelloWorld/HelloWorldOptions.py" | grep "leaving with code" || echo "FAILED"
