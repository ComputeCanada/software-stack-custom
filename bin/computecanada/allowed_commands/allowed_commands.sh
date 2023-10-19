#!/bin/bash

THIS_SCRIPT=$(basename $0)

function reject_command() {
	echo "Command rejected by $THIS_SCRIPT: $SSH_ORIGINAL_COMMAND"
	logger -t automation -p local0.info "Command rejected by $THIS_SCRIPT for user $USER: $SSH_ORIGINAL_COMMAND"

}
logger -t automation -p local0.info "Command called by $THIS_SCRIPT for user $USER: $SSH_ORIGINAL_COMMAND"
case "$SSH_ORIGINAL_COMMAND" in
	# always available commands
	ls*|cat*|cd*)
		$SSH_ORIGINAL_COMMAND
	;;
	# file commands
	mv*|cp*|rm*|mkdir*)
		if [[ "$THIS_SCRIPT" == "allowed_command.sh" || "$THIS_SCRIPT" == "file_commands.sh" ]]; then
			$SSH_ORIGINAL_COMMAND
		else
			reject_command
		fi
	;;
	# git
	git*)
		if [[ "$THIS_SCRIPT" == "allowed_command.sh" || "$THIS_SCRIPT" == "git_commands.sh" ]]; then
			$SSH_ORIGINAL_COMMAND
		else
			reject_command
		fi
	;;
	# archiving commands
	tar*|dar*|gzip*|zip*|bzip2*)
		if [[ "$THIS_SCRIPT" == "allowed_command.sh" || "$THIS_SCRIPT" == "archiving_commands.sh" ]]; then
			$SSH_ORIGINAL_COMMAND
		else
			reject_command
		fi
	;;
	# rsync
	rsync*)
		if [[ "$THIS_SCRIPT" == "allowed_command.sh" || "$THIS_SCRIPT" == "transfer_commands.sh" ]]; then
			$SSH_ORIGINAL_COMMAND
		else
			reject_command
		fi
	;;
	# sftp and new scp
	/usr/libexec/openssh/sftp-server*)
		if [[ "$THIS_SCRIPT" == "allowed_command.sh" || "$THIS_SCRIPT" == "transfer_commands.sh" ]]; then
			$SSH_ORIGINAL_COMMAND
		else
			reject_command
		fi
	;;
	# old scp
	scp*)
		if [[ "$THIS_SCRIPT" == "allowed_command.sh" || "$THIS_SCRIPT" == "transfer_commands.sh" ]]; then
			$SSH_ORIGINAL_COMMAND
		else
			reject_command
		fi
	;;
	# slurm commands
	squeue*|scancel*|sbatch*|scontrol*|sq*)
		if [[ "$THIS_SCRIPT" == "allowed_command.sh" || "$THIS_SCRIPT" == "slurm_commands.sh" ]]; then
			$SSH_ORIGINAL_COMMAND
		else
			reject_command
		fi
	;;
	*)
		reject_command
		;;
esac
