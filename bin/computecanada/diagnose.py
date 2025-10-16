#!/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3/usr/bin/python
import os
import sys
import argparse
import subprocess

# default values on most clusters
CONF = {
    'slurm_bin_dir': '/opt/software/slurm/bin',
    'equals': "=======",
    'ospath': "/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3/usr",
    'max_lines': 500
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

    parser_show = subparsers.add_parser('show', help='Show path content')
    parser_show.add_argument('path', default=None, type=validate_path, help='Path to show')
    parser_show.set_defaults(func=show)

    parser_env = subparsers.add_parser('env', help='Show environment variables')
    parser_env.set_defaults(func=env)

    return parser

def job_script(args):
    if args.job_id:
        try:
            code, output, error = run_command(f"{CONF['slurm_bin_dir']}/scontrol write batch_script {args.job_id} -")
            fatal_assert(code, f"Error showing job {args.job_id}, is it owned by user {args.username} ?\n{error}")
            print(f"{CONF['equals']}\n{output}\n{CONF['equals']}")
        except Exception as e:
            fatal(f"Unknown error: {e}")

def inspect(args):
    if args.path:
        path = args.path
        try:
            commands = [f"{CONF['ospath']}/bin/ls -ld", f"{CONF['ospath']}/bin/getfacl", f"{CONF['ospath']}/bin/file"]

            code, output, error = run_command(f"{CONF['ospath']}/bin/file {path}")
            if code and 'ELF' in output and 'executable' in output:
                commands += [f"{CONF['ospath']}/bin/patchelf --print-interpreter"]
            if code and 'ELF' in output:
                commands += [f"{CONF['ospath']}/bin/patchelf --print-rpath", f"{CONF['ospath']}/bin/ldd"]

            for command in [f"{x} {path}" for x in commands]:
                code, output, error = run_command(command)
                fatal_assert(code, f"Error running {command}, \n{error}")
                print(f"{CONF['equals']}\n{command}\n{output}\n{CONF['equals']}")

        except Exception as e:
            fatal(f"Unknown error: {e}")

def show(args):
    if args.path:
        path = args.path
        try:
            if os.path.isdir(path):
                cmd = f"{CONF['ospath']}/bin/ls -lh {path}"
                code, output, error = run_command(cmd)
                fatal_assert(code, f"Unknown error running {cmd}: {code}\n{error}")
                print(f"{cmd}:\n{output}")
            else:
                cmd = f"{CONF['ospath']}/bin/file {path}"
                code, output, error = run_command(cmd)
                fatal_assert(code, f"Unknown error running {cmd}: {code}\n{error}")
                if 'text' in output:
                    cmd = f"{CONF['ospath']}/bin/wc -l {path}"
                    code, output, error = run_command(cmd)
                    fatal_assert(code, f"Unknown error running {cmd}: {code}\n{error}")
                    num_lines = int(output.split(' ')[0])
                    if num_lines > CONF['max_lines']:
                        print(f"File {path} has more than {CONF['max_lines']} lines ({num_lines}), displaying only the first {CONF['max_lines']}")
                    cmd = f"{CONF['ospath']}/bin/head -n {CONF['max_lines']} {path}"
                    code, output, error = run_command(cmd)
                    fatal_assert(code, f"Unknown error running {cmd}: {code}\n{error}")
                    print(f"{cmd}:\n{CONF['equals']}\n{output}\n{CONF['equals']}")
                else:
                    print(f"Can't show file {path}, not a text file:\n{output}")

        except Exception as e:
            fatal(f"Unknown error: {e}")

def env(args):
    env = os.environ
    for k in sorted(env.keys()):
        print(f"{k}: {env[k]}")

def main():
    args = create_argparser().parse_args()

    # get current username
    args.username = os.getlogin()
    cluster_customize()

    args.func(args)

    exit(0)

if __name__ == "__main__":
    main()

