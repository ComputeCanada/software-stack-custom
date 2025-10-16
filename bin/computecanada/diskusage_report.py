#!/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3/usr/bin/python
#import configparser
import argparse
import subprocess
import glob
import os
import sys
from pathlib import Path
from datetime import datetime
import pwd

SUPPORTED_FS_TYPES = {'lustre', 'nfs', 'gpfs', 'nfs4'}

CONFIG_PATH = "/cvmfs/soft.computecanada.ca/custom/bin/computecanada/diskusage_report_configs/"
DEFAULT_CONFIG = {
    'filesystems': {
        '/home': {'quota_type': 'user'},
        '/scratch': {'quota_type': 'user'},
        '/project': {'quota_type': 'group'},
        '/nearline': {'quota_type': 'group'},
    },
    'symlink_paths': ['scratch', ('projects', '*'), ('nearline', '*'), ('links', '*'), ('links/projects', '*'), ('links/nearline', '*')],
    'gpfs_diskusage_location': None,
}
cfg = DEFAULT_CONFIG

parser = argparse.ArgumentParser()
parser.add_argument("--home", default=False, action='store_true', help="Display information for the home filesystem")
parser.add_argument("--scratch", default=False, action='store_true', help="Display information for the scratch filesystem")
parser.add_argument("--project", default=False, action='store_true', help="Display information for the project filesystem")
parser.add_argument("--nearline", default=False, action='store_true', help="Display information for the nearline filesystem")
parser.add_argument("--per_user", default=False, action='store_true', help="Display per-user breakdown if available")
parser.add_argument("--all_users", default=False, action='store_true', help="Display information for all users of the project")
args = parser.parse_args()

def get_network_filesystems():
    network_fs = {}
    found_gpfs = False
    with open('/proc/mounts', 'r') as f:
        for mount_line in f.readlines():
            device, mount_point, fs_type, *_ = tuple(mount_line.split())
            if fs_type in SUPPORTED_FS_TYPES and mount_point in cfg['filesystems'].keys():
                network_fs[mount_point] = {'fs_type': fs_type}
            elif fs_type == 'gpfs':
                found_gpfs = True
    if found_gpfs:
        for fs in cfg['filesystems'].keys():
            if os.path.isdir( os.path.join('/gpfs', fs)):
                network_fs[fs] = {'fs_type': 'gpfs'}
    if len(network_fs) == 0:
        print("ERROR: Did not find any supported filesystems. Exiting.")
        sys.exit(1)
    return network_fs

def get_command_output(command):
    res = subprocess.run(command, shell=True, capture_output=True, text=True)
    if res.returncode == 0:
        return res.stdout.strip()
    else:
        return ''

# get list of absolute paths that are relevant to the user based on the symlinks locations
def get_relevant_paths():
    # keep only symlinks named scratch or any of the groups of the user
    valid_link_names = ['scratch'] + get_command_output('groups 2>/dev/null').split(' ')

    home = os.environ['HOME']
    paths = set()
    paths.add(home)
    for path in cfg['symlink_paths']:
        if isinstance(path, str):
            try_path = os.path.join(home, path)
            if os.path.islink(try_path) and os.path.basename(try_path) in valid_link_names:
                paths.add(os.path.realpath(try_path))
        elif isinstance(path, tuple):
            try_dir = os.path.join(home, path[0])
            if os.path.isdir(try_dir):
                try_subpaths = glob.glob(os.path.join(try_dir, path[1]))
                for subpath in try_subpaths:
                    if os.path.islink(subpath) and os.path.basename(subpath) in valid_link_names:
                        paths.add(os.path.realpath(subpath))

    return paths

# collect information on paths, such as owner, group, lustre project, filesystem, filesystem type
def get_paths_info(paths, filesystems):
    paths_info = {}
    for path in paths:
        path = Path(path)
        try:
            if not path.is_dir(): continue
            path_info = {}
            path_info['path'] = str(path.resolve())
            path_info['user'] = path.owner()
            path_info['group'] = path.group()
        except:
            print(f"Error retrieving information for {path}")
            continue

        # if the symlink does not point to a filesystem that was requested, skip
        try:
            path_info['filesystem'] = [fs for fs in filesystems.keys() if fs in str(path.resolve())][0]
        except:
            continue
        path_info['fs_type'] = filesystems[path_info['filesystem']]['fs_type']
        if path_info['fs_type'] == 'lustre':
            project = get_command_output(f"/usr/bin/lfs project -d {path.resolve()} 2>/dev/null | awk '{{print $1}}'")
            if project != "0":
                path_info['project'] = project
            else:
                path_info['project'] = None
        else:
            path_info['project'] = None

        if path_info['fs_type'] == 'nfs':
            if get_command_output(f"df {path_info['path']} -h | grep {path_info['filesystem']}") != get_command_output(f"df {path_info['filesystem']} -h | grep {path_info['filesystem']}"):
                path_info['project'] = path_info['group']
            else:
                path_info['project'] = None

        if path_info['project']:
            path_info['quota_type'] = 'project'
        else:
            path_info['quota_type'] = cfg['filesystems'][path_info['filesystem']]['quota_type']

        paths_info[str(path.resolve())] = path_info
    return paths_info

def get_quota(path_info, quota_type, quota_identity=None):
    fs_type = path_info['fs_type']
    identity = quota_identity or path_info[quota_type]
    filesystem = path_info['filesystem']
    if fs_type == 'lustre':
        flag = {'project': '-p', 'user': '-u', 'group': '-g'}[quota_type]
        command = f"/usr/bin/lfs quota -q {flag} {identity} {filesystem} | grep '{filesystem}' |awk '{{print $2,$3,$6,$7}}' | sed -e 's/\*//g'"
        data = get_command_output(command).split(' ')
    elif fs_type in ['nfs', 'nfs4']:
        if quota_type == 'user':
            command = f"/usr/bin/quota --no-wrap -f {filesystem} | grep {filesystem} | awk '{{print $2,$3,$5,$6}}'"
            data = get_command_output(command).split(' ')
        if quota_type == 'project':
            command = f"df {path_info['path']} | grep {filesystem} | awk '{{print $3,$2}}'"
            data = get_command_output(command).split(' ')
            command = f"df --inodes {path_info['path']} | grep {filesystem} | awk '{{print $3,$2}}'"
            data += get_command_output(command).split(' ')
    elif fs_type == 'gpfs':
        if quota_type == 'user':
            qt = 'u'
            qtype = 'USR'
        elif quota_type == 'group':
            qt = 'g'
            qtype = 'GRP'
        fn = os.path.join(cfg['gpfs_diskusage_location'], qt, filesystem.removeprefix('/'), identity)
        with open(fn, 'r') as quota_file:
            line = quota_file.readlines()[-1]
            tokens = line.split()
        # GPFS quota file format is:
        # YYYY-mm-dd_HH:MM  Name           type  KB  quota  limit  in_doubt  grace  |  files  quota  limit  in_doubt  grace
        # or
        # YYYY-mm-dd_HH:MM  Name  fileset  type  KB  quota  limit  in_doubt  grace  |  files  quota  limit  in_doubt  grace
        # Since a column with "fileset" may or may not be present and "grace" may contain a space (e.g. "2 days") we need to 
        # find the index of USR or GRP (type column) or the '|' that separates Block Limits from File Limits.
        data = [tokens[tokens.index(qtype)+1], tokens[tokens.index(qtype)+2], tokens[tokens.index('|')+1], tokens[tokens.index('|')+2]]

    if isinstance(data, list) and len(data) == 4:
        quota_info = {}
        quota_info['quota_type'] = quota_type
        quota_info['identity'] = identity
        quota_info['identity_name'] = pwd.getpwuid(os.getuid())[0] if quota_type == 'user' else quota_identity or path_info['group']
        quota_info['space_used_raw'] = int(data[0].replace('*',''))
        quota_info['space_quota_raw'] = int(data[1].replace('*',''))
        quota_info['file_used'] = int(data[2].replace('*',''))
        quota_info['file_quota'] = int(data[3].replace('*',''))
        quota_info['space_used_bytes'] = quota_info['space_used_raw'] * int(cfg['filesystems'][filesystem].get('factor_to_bytes', cfg.get('factor_to_bytes', 1024)))
        quota_info['space_quota_bytes'] = quota_info['space_quota_raw'] * int(cfg['filesystems'][filesystem].get('factor_to_bytes', cfg.get('factor_to_bytes', 1024)))
        return quota_info
    else:
        return None

def get_quotas(paths_info, filesystems=None):
    if not filesystems: filesystems = cfg['filesystems'].keys()
    for filesystem in filesystems:
        for path, path_info in paths_info.items():
            if path_info['filesystem'] != filesystem: continue
            path_info['quotas'] = []
            path_info['quotas'] += [get_quota(path_info, path_info['quota_type'])]

        # add extra quotas
        for extra_quota in cfg['filesystems'][filesystem].get('extra_quotas', []):
            for path, path_info in paths_info.items():
                if path_info['filesystem'] != filesystem: continue
                if extra_quota['quota_id'] == 'user':
                    username = pwd.getpwuid(os.getuid())[0]
                    path_info['quotas'] += [get_quota(path_info, extra_quota['quota_type'], username)]
                else:
                    path_info['quotas'] += [get_quota(path_info, extra_quota['quota_type'], path_info[extra_quota['quota_id']])]
                break

def sizeof_fmt(num, suffix="B", scale=1024, units=None):
    if not units:
        if scale == 1024:
            units = ("  ", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi", "Yi")
        elif scale == 1000:
            units = (" ", "K", "M", "G", "T", "P", "E", "Z", "Y")
        else:
            return "Error, please provide units to sizeof_fmt"

    for unit in units:
        if abs(num) < 10*scale:
            return f"{num:4.0f}{unit}{suffix}"
        num /= scale
    return f"{num:.0f}{units[-1]}{suffix}"

def report_quotas(paths_info):
    header = ["Description", "Space", "# of files"]
    has_explorer = False
    print(f"{header[0]:>39} {header[1]:>20} {header[2]:>18}")
    for fs in cfg['filesystems'].keys():
        space_display_scale = cfg['filesystems'][fs].get('space_display_scale', cfg.get('space_display_scale', 1024))
        get_quotas(paths_info, [fs])
        has_explorer |= add_explorer_commands(paths_info, fs)
        for path, path_info in paths_info.items():
            if path_info['filesystem'] == fs:
                for quota_info in path_info['quotas']:
                    if not quota_info:
                        description = f"{path_info['path']} ({path_info['user']}/{path_info['group']})"
                        error = f"Unable to retrieve quota"
                        print(f"{description:>40} {error:>60}")
                        continue
                    quota_type = 'user' if path_info['filesystem'] in ('/home', '/scratch') else quota_info['quota_type']
                    description = f"{path_info['filesystem']} ({quota_type} {quota_info['identity_name']})"
                    space = f"{sizeof_fmt(quota_info['space_used_bytes'], scale=space_display_scale)}/{sizeof_fmt(quota_info['space_quota_bytes'], scale=space_display_scale)}"
                    files = f"{sizeof_fmt(quota_info['file_used'], suffix='', scale=1000)}/{sizeof_fmt(quota_info['file_quota'], suffix='', scale=1000)}"
                    print(f"{description:>39} {space:>20} {files:>18}")

        # display breakdowns per user if requested
        for path, path_info in paths_info.items():
            if path_info['filesystem'] == fs:
                if args.per_user:
                    stats_path = os.path.join(fs, ".stats", f"{path_info['group']}.json")
                    if os.path.isfile(stats_path):
                        timestamp = Path(stats_path).stat().st_mtime
                        m_time = datetime.fromtimestamp(timestamp)
                        print(f"\nBreakdown for project {path_info['group']} (Last update: {m_time:%Y-%m-%d %H:%M:%S})")
                        diskusage_rbh_arg = ["--all_users"] if args.all_users else []
                        subprocess.run(["diskusage_rbh", fs[1:], path_info['group']] + diskusage_rbh_arg)
                        print("\n")


    # report breakdown commands
    if has_explorer:
        print("\nDisk usage can be explored using the following commands")
        for fs in cfg['filesystems'].keys():
            for path, path_info in paths_info.items():
                if path_info['filesystem'] == fs:
                    if 'explorer_command' in path_info:
                        print(path_info['explorer_command'])

def add_explorer_commands(paths_info, filesystem):
    has_explorer = False
    for path, path_info in paths_info.items():
        if path_info['filesystem'] == filesystem:
            db_path = os.path.join(filesystem, ".duc_databases", f"{path_info['group']}.sqlite")
            if os.path.isfile(db_path):
                timestamp = Path(db_path).stat().st_mtime
                m_time = datetime.fromtimestamp(timestamp)
                path_to_explore = f"{filesystem}/{path_info['group']}"
                path_info['explorer_command'] = f"diskusage_explorer {path_to_explore:24}  # Last update: {m_time:%Y-%m-%d %H:%M:%S}"
                has_explorer = True
    return has_explorer

def deep_update_dict(dict1, dict2):
    # for each k, v in dict1, merge the corresponding values from dict2
    for k, v in dict1.items():
        if k in dict2.keys():
            if isinstance(v, dict):
                # merge the next level if it's a dict
                deep_update_dict(v, dict2[k])
            elif isinstance(v, list):
                # combine lists if it's a list
                dict1[k] += dict2[k]
            else:
                # overwrite value if it's anything else
                dict1[k] = dict2[k]

    # for each key in dict2 that is not in dict1, add them to dict1
    for k, v in dict2.items():
        if k not in dict1.keys():
            dict1[k] = v

if __name__ == "__main__":
    config_file = os.getenv('DISKUSAGE_REPORT_CONFIG_FILE', os.path.join(CONFIG_PATH, f"{os.getenv('CC_CLUSTER')}.yaml"))
    config_file = Path(config_file)
    if os.path.isfile(config_file.resolve()):
        import yaml
        with open(config_file) as f:
            deep_update_dict(cfg, yaml.load(f, Loader=yaml.FullLoader))

    if any([args.scratch, args.nearline, args.project, args.home]):
        if not args.home: cfg['filesystems'].pop('/home', None)
        if not args.scratch: cfg['filesystems'].pop('/scratch', None)
        if not args.project: cfg['filesystems'].pop('/project', None)
        if not args.nearline: cfg['filesystems'].pop('/nearline', None)

    relevant_paths = get_relevant_paths()
    network_filesystems = get_network_filesystems()
    paths_info = get_paths_info(relevant_paths, network_filesystems)
    report_quotas(paths_info)

    if not args.per_user and any([x in cfg['filesystems'].keys() for x in ['/project', '/nearline']]):
        print("--")
        print("On some clusters, a break down per user may be available by adding the option '--per_user'.")

