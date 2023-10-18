#!/bin/bash

echo "Command used: $SSH_ORIGINAL_COMMAND" >> commands.log
logger -t automation -p local0.info "Command used by $USER: $SSH_ORIGINAL_COMMAND"
case "$SSH_ORIGINAL_COMMAND" in
	# file commands
	ls*|mv*|cp*|rm*|mkdir*)
		$SSH_ORIGINAL_COMMAND
	;;
	# archiving commands
	tar*|dar*|gzip*|zip*|bzip2*)
		$SSH_ORIGINAL_COMMAND
	;;
	# rsync
	rsync*)
		$SSH_ORIGINAL_COMMAND
	;;
	# sftp and new scp
	/usr/libexec/openssh/sftp-server*)
		$SSH_ORIGINAL_COMMAND
	;;
	# old scp
	scp*)
		$SSH_ORIGINAL_COMMAND
	;;
	# slurm commands
	squeue*|scancel*|sbatch*|scontrol*)
		$SSH_ORIGINAL_COMMAND
	;;
	*)
		echo "Command rejected: $SSH_ORIGINAL_COMMAND"
		logger -t automation -p local0.info "Command rejected by $USER: $SSH_ORIGINAL_COMMAND"
		;;
esac
