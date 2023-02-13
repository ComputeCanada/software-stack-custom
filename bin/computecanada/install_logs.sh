#!/bin/bash

cd /cvmfs/soft.computecanada.ca/easybuild/ebfiles_repo
if [[ -z $EBROOTGENTOO ]]; then
	YEAR="2017"
else
	YEAR="2020"
fi

names=$(for r in $(find . -iname "$1*.eb"); do echo $(basename $(dirname $r)); done | sort | uniq)
for name in $names; do
	echo "To see updates and who installed $name; visit https://github.com/ComputeCanada/easybuild-easyconfigs-installed-$RSNT_ARCH/commits/main/$YEAR/$name"
done

echo "==========================================================="
for version in $(find . -iname "$1*.eb"); do 
	filename=$(basename $version)
	name=$(basename $(dirname $version))
	echo "To see updates and who installed $filename; visit https://github.com/ComputeCanada/easybuild-easyconfigs-installed-$RSNT_ARCH/commits/main/$YEAR/$name/$filename"
done
echo "==========================================================="
