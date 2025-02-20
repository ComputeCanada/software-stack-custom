#!/bin/bash

set -f

THIS_SCRIPT=$(basename $0)

function reject_command() {
        echo "Command rejected by $THIS_SCRIPT: $SSH_ORIGINAL_COMMAND"
        logger -t automation -p local0.info "Command rejected by $THIS_SCRIPT for user $USER: $SSH_ORIGINAL_COMMAND"
}

logger -t automation -p local0.info "Command called by $THIS_SCRIPT for user $USER: $SSH_ORIGINAL_COMMAND"

ALLOWED_DIR=$1

G_SFTP="/usr/libexec/openssh/sftp-server"
G_SBATCH="^bash -l -c 'cd ['\"]+${ALLOWED_DIR}.*['\"]+ && \( sbatch .* \)'$"
G_RM="^bash -l -c 'cd ['\"]+${ALLOWED_DIR}.*['\"]+ && \( rm.* \)'$"
G_SQUEUE="^bash -l -c 'cd ['\"]+${HOME}['\"]+ && \( SLURM_TIME_FORMAT=['\"]+standard['\"]+ squeue.* \)'$"
G_SACCT="^bash -l -c 'cd ['\"]+${HOME}['\"]+ && \( sacct .* \)'$"
G_WHOAMI="^bash -l -c 'cd ['\"]+${HOME}['\"]+ && \( whoami \)'$"
G_WHOAMI1="^bash -c 'cd ['\"]+${HOME}['\"]+ && \( whoami \)'$"
G_ECHO="^bash -l -c 'cd ['\"]+${HOME}['\"]+ && \( echo -n \)'$"

# add versions for case where there are no quotes around ALLOWED_DIR
G_SBATCH_NQ="^bash -l -c 'cd ${ALLOWED_DIR}.* &&\s+\( sbatch .* \)'$"
G_RM_NQ="^bash -l -c 'cd ${ALLOWED_DIR}.* &&\s+\( rm.* \)'$"
G_SQUEUE_NQ="^bash -l -c 'cd ${HOME} &&\s+\( SLURM_TIME_FORMAT=['\"]+standard['\"]+ squeue.* \)'$"
G_SACCT_NQ="^bash -l -c 'cd ${HOME} &&\s+\( sacct .* \)'$"
G_WHOAMI_NQ="^bash -l -c 'cd ${HOME} &&\s+\( whoami \)'$"
G_WHOAMI1_NQ="^bash -c 'cd ${HOME} &&\s+\( whoami \)'$"
G_ECHO_NQ="^bash -l -c 'cd ${HOME} &&\s+\( echo -n \)'$"

declare -a arr=("$G_SFTP" "$G_SBATCH" "$G_RM" "$G_SQUEUE" "$G_SACCT" "$G_WHOAMI" "$G_WHOAMI1" "$G_ECHO" "$G_SBATCH_NQ" "$G_RM_NQ" "$G_SQUEUE_NQ" "$G_SACCT_NQ" "$G_WHOAMI_NQ" "$G_WHOAMI1_NQ" "$G_ECHO_NQ")

COMMAND_PASSED=false
for i in "${arr[@]}"
do
   (echo $SSH_ORIGINAL_COMMAND | grep -Eq "$i") && COMMAND_PASSED=true
done

# checks to prevent launch of additional commands
#

(echo $SSH_ORIGINAL_COMMAND | grep -Eq "\.\.") && COMMAND_PASSED=false
(echo $SSH_ORIGINAL_COMMAND | grep -Eq ";") && COMMAND_PASSED=false
(echo $SSH_ORIGINAL_COMMAND | grep -Eq "&&.*&&") && COMMAND_PASSED=false
(echo $SSH_ORIGINAL_COMMAND | grep -Eq "\|") && COMMAND_PASSED=false

# uncomment these 3 lines if debugging
# date >> $HOME/command.log
# echo "$SSH_ORIGINAL_COMMAND" >> $HOME/command.log
# echo "$COMMAND_PASSED" >> $HOME/command.log

if $COMMAND_PASSED
then
    eval $SSH_ORIGINAL_COMMAND
else
    reject_command 
fi

