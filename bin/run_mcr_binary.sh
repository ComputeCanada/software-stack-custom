#!/bin/sh
# script for execution of deployed applications
#
# Sets up the MATLAB runtime environment for the current $ARCH and executes 
# the specified command.
#
if [ "x$1" = "x" ]; then
	echo Usage:
	echo		$0 \<software\> args
else
	exe=$1
	shift 1
	if [[ $(patchelf --print-interpreter $exe) != "/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/lib/ld-linux-x86-64.so.2" ]]; then
		echo "------------------------------------------"
		echo "This binary was not compiled on this plateform. Please run the command \"setrpaths.sh --path $exe\" to make it compatible with this plateform."
		echo "Cet exécutable n'a pas été compilé sur cette plateforme. Veuillez exécuter la commande \"setrpaths.sh --path $exe\" pour le rendre compatible avec cette plateform."
		echo "------------------------------------------"
		exit 1
	fi
	if [[ -z "${MCRROOT}" ]]; then
		echo "------------------------------------------"
		echo "No mcr module has been loaded. Please load an mcr module before running this script. Run \"module spider mcr\" to find one."
		echo "Aucun module mcr n'a été chargé. Veuillez charger un module mcr avant d'exécuter ce script. Exécuter \"module spider mcr\" pour en trouver un."
		echo "------------------------------------------"
		exit 2
	fi
	echo Setting up environment variables
	echo "------------------------------------------"

	LD_LIBRARY_PATH=.:${MCRROOT}/runtime/glnxa64 ;
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64 ;
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64;

	if [[ "$EBVERSIONMCR" == "R2013a" ]]; then
	      	MCRJRE=${MCRROOT}/sys/java/jre/glnxa64/jre/lib/amd64 ;
		LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/native_threads ;
		LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/server ;
		LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/client ;
		LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE} ;
	fi
	if [[ "$EBVERSIONMCR" =~ R201[23][ab] ]]; then 
		XAPPLRESDIR=${MCRROOT}/X11/app-defaults ;
	fi
	if [[ $EBVERSIONMCR =~ R201[5678][ab] ]]; then
		LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64;
	fi

	LD_LIBRARY_PATH=${LD_LIBRARY_PATH};  #:${NIXUSER_PROFILE}/lib;
	
	export LD_LIBRARY_PATH;
	echo LD_LIBRARY_PATH is ${LD_LIBRARY_PATH};
	args=
	while [ $# -gt 0 ]; do
		token=$1
		args="${args} \"${token}\"" 
		shift
	done
	# test if it is an absolute path (i.e. starts with / or with ~)
	if [[ "${exe:0:1}" == / || "${exe:0:2}" == ~[/a-z] ]]; then
		eval "\"$exe\"" $args
	# or a relative path
	else
		eval "\"./$exe\"" $args
	fi
fi
exit

