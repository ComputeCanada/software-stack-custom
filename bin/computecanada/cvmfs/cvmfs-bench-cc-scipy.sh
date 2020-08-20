#!/bin/bash

# set up CC environment directly
for file in /cvmfs/soft.computecanada.ca/config/profile.d/*.sh; do
  if [[ -r "$file" ]]; then
    source $file
  fi
done

module load StdEnv/2020 python scipy-stack

# according to one test this takes about ~ 1 min with cold cache, but only ~ .7 s after that. 
# This benchmark appears to be more bandwidth-intensive, loads about 350 MB into client cache
# as of 20200730.
# Seems to require the AVX512 arch for these python modules to be available.

python -c 'import scipy.cluster; import scipy.cluster.hierarchy; import scipy.cluster.vq; import scipy.constants; import scipy.fft; import scipy.fftpack; import scipy.fftpack.convolve; import scipy.integrate; import scipy.interpolate; import scipy.io; import scipy.io.arff; import scipy.io.wavfile; import scipy.linalg; import scipy.linalg.blas; import scipy.linalg.cython_blas; import scipy.linalg.cython_lapack; import scipy.linalg.interpolative; import scipy.linalg.lapack; import scipy.misc; import scipy.ndimage; import scipy.odr; import scipy.optimize; import scipy.optimize.cython_optimize;import scipy.optimize.nonlin; import scipy.signal; import scipy.signal.windows; import scipy.sparse; import scipy.sparse.csgraph; import scipy.sparse.linalg; import scipy.spatial; import scipy.spatial.distance; import scipy.spatial.transform; import scipy.special; import scipy.special.cython_special; import scipy.stats; import scipy.stats.mstats'
