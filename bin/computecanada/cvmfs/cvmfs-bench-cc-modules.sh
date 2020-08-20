#!/bin/bash

# set up CC environment directly
for file in /cvmfs/soft.computecanada.ca/config/profile.d/*.sh; do
  if [[ -r "$file" ]]; then
    source $file
  fi
done

# search the whole module tree. As of 20200730 this requires loading 
# about 54 MB of data into the client cache. Can take ~> 1 minute,
# seems more latency sensitive.
module spider

