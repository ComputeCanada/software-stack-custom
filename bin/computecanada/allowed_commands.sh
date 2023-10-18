#!/bin/bash

logger -t automation -p local0.info "Command used by $USER: $SSH_ORIGINAL_COMMAND"
case "$SSH_ORIGINAL_COMMAND" in
	# file commands
	ls*|mv*|cp*|rm*|mkdir*|cat*)
		$SSH_ORIGINAL_COMMAND
	;;
	# git
	git*)
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
	squeue*|scancel*|sbatch*|scontrol*|sq*)
		$SSH_ORIGINAL_COMMAND
	;;
	*)
		echo "Command rejected: $SSH_ORIGINAL_COMMAND"
		logger -t automation -p local0.info "Command rejected by $USER: $SSH_ORIGINAL_COMMAND"
		;;
esac
