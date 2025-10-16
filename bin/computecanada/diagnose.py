#!/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3/usr/bin/python
import os
import sys
import argparse
import subprocess

# default values on most clusters
CONF = {
    'slurm_bin_dir': '/opt/software/slurm/bin'
}
def cluster_customize():
    cluster = os.environ.get('CC_CLUSTER', 'computecanada')
    if cluster == 'killarney':
        CONF['slurm_bin_dir'] = '/cm/shared/apps/slurm/current/bin'
    if cluster == 'vulcan':
        CONF['slurm_bin_dir'] = '/usr/bin'
    if cluster in ['tamia', 'niagara', 'trillium']:
        CONF['slurm_bin_dir'] = '/opt/slurm/bin'

def fatal(message: str, exitcode=1):
    print(f'ERROR: {message}',file=sys.stderr)
    exit(exitcode)

def fatal_assert(condition: bool, message: str, exitcode=1):
    if not condition:
        fatal(message, exitcode)

def run_command(command: str, args: list = []) -> bool:
    try:
        args_str = ' '.join(args)
        result = subprocess.run([f'{command} {args_str}'], shell=True, text=True, timeout=30, capture_output=True)
    except subprocess.TimeoutExpired:
        fatal(f"Command timeout: {command}", 201)
    if result.returncode == 0:
        return True, result.stdout, result.stderr
    else:
        return False, result.stdout, result.stderr

def validate_positive_number(val: str):
    if val is not str:
        val = str(val)
    fatal_assert(val.isdigit() and int(val) >= 0, f"Invalid value: {val}")
    return int(val)

def validate_path(val: str):
    fatal_assert(os.path.exists(val), f"Path {val} does not exist")
    try:
        statinfo = os.stat(val)
    except:
        fatal_assert(False, f"Could not retrieve stat info for path {val}")
    return val

def create_argparser():
    class HelpFormatter(argparse.RawDescriptionHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
        """ Dummy class for RawDescription and ArgumentDefault formatter """

    description = "diagnose: diagnostic script for various problems."
    epilog = ""

    parser = argparse.ArgumentParser(prog="diagnose", formatter_class=HelpFormatter, description=description, epilog=epilog)
    subparsers = parser.add_subparsers(dest='action', required=False, title='subcommands')

    parser_job_script = subparsers.add_parser('job_script', help='Show job script')
    parser_job_script.add_argument('job_id', default=None, type=validate_positive_number, help='Job ID for which to show the job')
    parser_job_script.set_defaults(func=job_script)

    parser_inspect = subparsers.add_parser('inspect', help='Inspect file metadata')
    parser_inspect.add_argument('path', default=None, type=validate_path, help='Path to inspect')
    parser_inspect.set_defaults(func=inspect)

    return parser

def job_script(args):
    if args.job_id:
        try:
            code, output, error = run_command(f"{CONF['slurm_bin_dir']}/scontrol write batch_script {args.job_id} -")
            fatal_assert(code, f"Error showing job {args.job_id}, is it owned by user {args.username} ?\n{error}")
            print(f"=======\n{output}\n=======")
        except Exception as e:
            fatal(f"Unknown error: {e}")

def inspect(args):
    equals = "======="
    ospath = "/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3/usr"
    if args.path:
        path = args.path
        try:
            commands = [f"{ospath}/bin/ls -ld", f"{ospath}/bin/getfacl", f"{ospath}/bin/file"]

            code, output, error = run_command(f"{ospath}/bin/file {path}")
            if code and 'ELF' in output and 'executable' in output:
                commands += [f"{ospath}/bin/patchelf --print-interpreter"]
            if code and 'ELF' in output:
                commands += [f"{ospath}/bin/patchelf --print-rpath", f"{ospath}/bin/ldd"]

            for command in [f"{x} {path}" for x in commands]:
                code, output, error = run_command(command)
                fatal_assert(code, f"Error running {command}, \n{error}")
                print(f"{equals}\n{command}\n{output}\n{equals}")

        except Exception as e:
            fatal(f"Unknown error: {e}")

def main():
    args = create_argparser().parse_args()

    # get current username
    args.username = os.getlogin()
    cluster_customize()

    args.func(args)

    exit(0)

if __name__ == "__main__":
    main()

