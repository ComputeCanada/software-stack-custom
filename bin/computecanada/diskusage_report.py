#!/bin/env python
#import configparser
import argparse
import subprocess
import glob
import os
from pathlib import Path

SUPPORTED_FS_TYPES = ['lustre', 'nfs']
SUPPORTED_FS = ['/home', '/scratch', '/project', '/nearline']
SYMLINK_PATHS = ['scratch', ('projects', '*'), ('nearline', '*'), ('links', '*'), ('links/projects', '*'), ('links/nearline', '*')]
DEFAULT_QUOTA_TYPES = { '/home': 'user', '/scratch': 'user', '/project': 'group', '/nearline': 'group' }
SPACE_FACTOR = 1000

parser = argparse.ArgumentParser()
parser.add_argument("--home", default=False, action='store_true', help="Display information for the home filesystem")
parser.add_argument("--scratch", default=False, action='store_true', help="Display information for the scratch filesystem")
parser.add_argument("--project", default=False, action='store_true', help="Display information for the project filesystem")
parser.add_argument("--nearline", default=False, action='store_true', help="Display information for the nearline filesystem")
parser.add_argument("--per-user", default=False, action='store_true', help="Display per-user breakdown if available")
parser.add_argument("--all-user", default=False, action='store_true', help="Display information for all users of the project")
args = parser.parse_args()

def get_network_filesystems():
    network_fs = {}
    with open('/proc/mounts', 'r') as f:
        for mount_line in f.readlines():
            device, mount_point, fs_type, *_ = tuple(mount_line.split())
            if fs_type in SUPPORTED_FS_TYPES and mount_point in SUPPORTED_FS:
                network_fs[mount_point] = {'fs_type': fs_type}
    return network_fs

def get_command_output(command):
    res = subprocess.run(command, shell=True, capture_output=True, text=True)
    if res.returncode == 0:
        return res.stdout.strip()
    else:
        return None

# get list of absolute paths that are relevant to the user based on the symlinks locations
def get_relevant_paths():
    # keep only symlinks named scratch or any of the groups of the user
    valid_link_names = ['scratch'] + get_command_output('groups 2>/dev/null').split(' ')

    home = os.environ['HOME']
    paths = set()
    paths.add(home)
    for path in SYMLINK_PATHS:
        if isinstance(path, str):
            try_path = os.path.join(home, path)
            print(os.path.basename(try_path))
            if os.path.islink(try_path) and os.path.basename(try_path) in valid_link_names:
                paths.add(os.path.realpath(try_path))
        elif isinstance(path, tuple):
            try_dir = os.path.join(home, path[0])
            if os.path.isdir(try_dir):
                try_subpaths = glob.glob(os.path.join(try_dir, path[1]))
                for subpath in try_subpaths:
                    print(os.path.basename(subpath))
                    if os.path.islink(subpath) and os.path.basename(subpath) in valid_link_names:
                        paths.add(os.path.realpath(subpath))

    return paths

# collect information on paths, such as owner, group, lustre project, filesystem, filesystem type
def get_paths_info(paths, filesystems):
    paths_info = {}
    for path in paths:
        path = Path(path)
        path_info = {}
        path_info['user'] = path.owner()
        path_info['group'] = path.group()
        path_info['filesystem'] = [fs for fs in filesystems.keys() if fs in str(path.resolve())][0]
        path_info['fs_type'] = filesystems[path_info['filesystem']]['fs_type']
        if path_info['fs_type'] == 'lustre':
            path_info['project'] = get_command_output(f"/usr/bin/lfs project -d {path.resolve()} 2>/dev/null | awk '{{print $1}}'")
        else:
            path_info['project'] = None

        if path_info['project']:
            path_info['quota_type'] = 'project'
        else:
            path_info['quota_type'] = DEFAULT_QUOTA_TYPES[path_info['filesystem']]
        paths_info[str(path.resolve())] = path_info
    return paths_info

def get_quota(path_info, quota_type):
    fs_type = path_info['fs_type']
    identity = path_info[quota_type]
    filesystem = path_info['filesystem']

    if fs_type == 'lustre':
        flag = {'project': '-p', 'user': '-u', 'group': '-g'}[quota_type]
        command = f"/usr/bin/lfs quota -q {flag} {identity} {filesystem} | awk '{{print $2,$3,$6,$7}}' | sed -e 's/\*//g'"
    elif fs_type == 'nfs':
        command = f"/usr/bin/quota --no-wrap -f {filesystem} | grep {filesystem} | awk '{{print $2,$3,$5,$6}}'"

    data = get_command_output(command).split(' ')
    if isinstance(data, list) and len(data) == 4:
        quota_info = {}
        quota_info['quota_type'] = quota_type
        quota_info['identity'] = identity
        quota_info['identity_name'] = path_info['user'] if quota_type == 'user' else path_info['group']
        quota_info['space_used_raw'] = int(data[0])
        quota_info['space_quota_raw'] = int(data[1])
        quota_info['file_used'] = int(data[2])
        quota_info['file_quota'] = int(data[3])
        quota_info['space_used_bytes'] = quota_info['space_used_raw'] * SPACE_FACTOR
        quota_info['space_quota_bytes'] = quota_info['space_quota_raw'] * SPACE_FACTOR
        return quota_info
    else:
        return None

def get_quotas(paths_info):
    for path, path_info in paths_info.items():
        path_info['quotas'] = []
        path_info['quotas'] += [get_quota(path_info, path_info['quota_type'])]
        if path_info['fs_type'] == 'lustre' and path_info['filesystem'] == '/project' and path_info['quota_type'] != 'project':
            path_info['quotas'] += [get_quota(path_info, 'user')]


if __name__ == "__main__":
    relevant_paths = get_relevant_paths()
    print(relevant_paths)
    network_filesystems = get_network_filesystems()
    paths_info = get_paths_info(relevant_paths, network_filesystems)
    get_quotas(paths_info)
    for path, path_info in paths_info.items():
        print(path, path_info)
#    print(get_paths_info(get_relevant_paths(), get_network_filesystems()))
#    print(get_command_output("lfs project -d /home/mboisson"))
#    print(get_network_filesystems())
