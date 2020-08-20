#!/bin/bash

# start a container image and load python libraries, using unpacked.cern.ch repo

singularity exec /cvmfs/unpacked.cern.ch/registry.hub.docker.com/atlasml/ml-base:centos-py-3.6.8 python3 -c 'import numpy as np; import tensorflow as tf'

