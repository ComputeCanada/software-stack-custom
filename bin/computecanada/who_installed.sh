#!/bin/bash

cd /cvmfs/soft.computecanada.ca/easybuild/ebfiles_repo
names=$(for r in $(find . -iname "$1*.eb"); do echo $(basename $(dirname $r)); done | sort | uniq)
for name in $names; do
	echo "To see updates and who installed $name; visit https://github.com/ComputeCanada/easybuild-easyconfigs-installed-avx2/commits/main/2020/$name"
done

