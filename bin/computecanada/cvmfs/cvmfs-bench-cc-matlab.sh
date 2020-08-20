#!/bin/bash

# Pre-requisite: a MATLAB license, access to MATLAB license server, and access to restricted repository
# mkdir $HOME/.licenses 
# cp  /cvmfs/restricted.computecanada.ca/config/licenses/matlab/inst_uvic/cedar.lic $HOME/.licenses/matlab.lic

if [[ ! -d /cvmfs/restricted.computecanada.ca ]] ; then
  echo "ERROR: access to the restricted repository is required for MATLAB"
  exit 1
fi

# set up CC environment directly
for file in /cvmfs/soft.computecanada.ca/config/profile.d/*.sh; do
  if [[ -r "$file" ]]; then
    source $file
  fi
done

module load matlab/2018b

# initialize matlab and perform a very difficult computation
matlab -r "2 + 2; exit"

