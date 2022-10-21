#!/bin/bash
__SCRIPT_DIR__="$(dirname "$(realpath -eP "${BASH_SOURCE[0]}")")"

function mounted_paths_under_provided()
{
  (
    mount | awk '{ print $3 }' | grep "$1$"
    mount | awk '{ print $3 }' | grep "$1/$"
  ) | sort -u
}

function get_home_base_paths()
{
  realpath /home
}

function get_project_base_paths()
{
  if [ -d ~/projects/ ]; then
    for p in ~/projects/* ; do
      dirname "$(realpath "$p")"
    done | sort -u
  elif [ -e /project ]; then
    realpath /project
  fi
}

function get_scratch_base_paths()
{
  if [ -d ~/scratch/ ]; then
    dirname "$(realpath ~/scratch)"
  elif [ -e /scratch ]; then
    realpath /scratch
  fi
}

function get_apptainer_bind_mounts()
{
  # $1 is name
  # $2 is real path
  local mounted_paths
  mounted_paths=$(mounted_paths_under_provided "$2")
  if [ -n "${mounted_paths}" ]; then
    (
      get_"$1"_base_paths | sed -e 's/^/-B /'
      get_"$1"_base_paths | sed -e 's/^/-B /' -e 's|$|:'"$2"'|'
    ) | grep -v '^-B '"$2"':'"$2"'$' | sort -u | xargs echo
  fi
}

function get_apptainer_workdir_args()
{
  if [ -z ${SLURM_TMPDIR+x} ]; then
    if [ -d /localscratch ] && [ -w /localscratch ]; then
      echo '-W /localscratch'
    elif [ -d /localscratch/tmp ] && [ -w /localscratch/tmp ]; then
      echo '-W /localscratch/tmp'
    fi
  else
    echo "-W \${SLURM_TMPDIR}"
  fi
}

HOME_BIND_MOUNTS=$(get_apptainer_bind_mounts home /home)
PROJECT_BIND_MOUNTS=$(get_apptainer_bind_mounts project /project)
SCRATCH_BIND_MOUNTS=$(get_apptainer_bind_mounts scratch /scratch)
WORKDIR_OPTION=$(get_apptainer_workdir_args)

SCRIPT_NAME="$(basename "$0")"
if [ "${SCRIPT_NAME}" == 'get-apptainer-options.sh' ]; then
  cat << ZZEOF
On the system you are running this command, these are options to use when 
using Apptainer's or Singularity's instance start, exec, run, or shell 
commands:

ZZEOF

  if [ -n "${HOME_BIND_MOUNTS}" ]; then
    echo -e "  * To be able to access /home use: ${HOME_BIND_MOUNTS}\n"
  fi

  if [ -n "${PROJECT_BIND_MOUNTS}" ]; then
    echo -e "  * To be able to access /project use: ${PROJECT_BIND_MOUNTS}\n"
  fi

  if [ -n "${SCRATCH_BIND_MOUNTS}" ]; then
    echo -e "  * To be able to access /scratch use: ${SCRATCH_BIND_MOUNTS}\n"
  fi

  if [ -n "${CC_CLUSTER}" ]; then
    echo -e "  * Within an sbatch job use: -W \${SLURM_TMPDIR}\n"
  fi

  if [ -n "${WORKDIR_OPTION}" ]; then
    echo -e "  * When \${SLURM_TMPDIR} is not available use: ${WORKDIR_OPTION}\n"
  else
    cat << 'ZZEOF'
  * When ${SLURM_TMPDIR} is not available use: -W somedirectory
      - somedirectory is a directory you've created somewhere
        that you otherwise don't ocare about (e.g., so you can remove it when
        not using Apptainer).

ZZEOF
  fi
  cat << ZZEOF
NOTE: Always specifying the -W option is strongly recommended. If your 
      Apptainer jobs are mysteriously dying or not working, try using -W 
      if you're not already to see if that works before submitting a ticket.

ZZEOF
  exit 0
fi

###############################################################################

OUTPUT_OCCURRED=0
while [ $# -gt 0 ]; do
  case "$1" in
    --home)
      if [ -n "${HOME_BIND_MOUNTS}" ]; then
        echo -n "${HOME_BIND_MOUNTS} " 
        OUTPUT_OCCURRED=1
      fi
      ;;
    --project)
      if [ -n "${PROJECT_BIND_MOUNTS}" ]; then
        echo -n "${PROJECT_BIND_MOUNTS} " 
        OUTPUT_OCCURRED=1
      fi
      ;;
    --scratch)
      if [ -n "${SCRATCH_BIND_MOUNTS}" ]; then
        echo -n "${SCRATCH_BIND_MOUNTS} " 
        OUTPUT_OCCURRED=1
      fi
      ;;
    --workdir)  
      if [ -n "${WORKDIR_OPTION}" ]; then
        echo -n "${WORKDIR_OPTION} "
        OUTPUT_OCCURRED=1
      fi
      ;;
    --sbatch)
      if [ -n "${CC_CLUSTER}" ]; then
        echo -n "-W \${SLURM_TMPDIR} "
        OUTPUT_OCCURRED=1
      fi
      ;;
  esac
  shift
done
if [ ${OUTPUT_OCCURRED} -eq 1 ]; then
  echo ""
  exit 0
else
  cat >&2 << ZZEOF
Usage: $0 [--home] [--project] [--scratch] [--workdir | --sbatch]
       --home is the -B option to use to bind mount /home
       --project is the -B option to use to bind mount /project
       --scratch is the -B option to use to bind mount /scratch
       --sbatch is the -W option to use when within an sbatch job
       --workdir is the -W option to use when not within an sbatch job
ZZEOF
  exit 127
fi

