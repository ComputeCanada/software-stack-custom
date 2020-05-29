#!/bin/bash
cd /cvmfs/soft.computecanada.ca/easybuild/ebfiles_repo

for r in $(find . -iname "$1*.eb"); do 
	v=$(git blame $r | awk '{print $2,$3,$4,$5}' | sort | uniq | sed -e "s/^(//g")
	IFS=$'\n'
	for l in $v; do
		echo $r $l
	done
done | sort -k4 

