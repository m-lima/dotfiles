#!/usr/bin/env python3

import datetime
import os
import subprocess
import sys

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def fatal(*args, **kwargs):
    eprint('[31mError:[m', *args, **kwargs)
    sys.exit(1)

if len(sys.argv) != 2:
    fatal('Expected one parameter')

def run(*args):
    return subprocess.run(args, capture_output=True).stdout

def get_subvolumes():
    subvolumes = []
    lines = run('sudo', 'btrfs', 'subvolume', 'list', '/').splitlines()
    for line in lines:
        parts = line.split()
        level = int(parts[6])
        if level >= 256:
            continue
        subvolumes.append(parts[8].decode())
    return subvolumes

def get_mounts():
    mounts = {}
    with open('/etc/fstab') as fstab:
        for line in fstab:
            line = line.lstrip()
            if len(line) == 0 or line[0] == '#':
                continue

            parts = line.split()
            if len(parts) != 6 or parts[2] != 'btrfs':
                continue

            opts = parts[3].split(',')
            for opt in opts:
                if opt.startswith('subvol='):
                    subvol = opt[len('subvol='):]
                    if subvol in mounts and len(mounts[subvol]) > 0:
                        eprint(f'Multiple mountpoints for {subvol}')
                    else:
                        mounts[subvol] = parts[1]
    return mounts

def compare_mount_subvolume(mounts, subvolumes):
    mounts = list(mounts.keys())
    mounts.sort()
    subvolumes.sort()

    if mounts != subvolumes:
        eprint('Mismatch between mounted volumes and btrfs subvolumes')
        eprint('Mounts: ', mounts)
        eprint('Subvols:', subvolumes)

def check():
    now = datetime.datetime.now()
    now = f'{now.year}-{now.month}-{now.day}'

    mounts = get_mounts()
    subvolumes = get_subvolumes()

    compare_mount_subvolume(mounts, subvolumes)

    volumes = []

    for subvolume in subvolumes:
        if subvolume == '@snapshots':
            continue
        elif subvolume == '@':
            snapshot = '_'
        else:
            snapshot = subvolume[1:]

        snapshot = f'/.snapshots/{snapshot}'
        if not os.path.isdir(snapshot):
            volumes.append((subvolume, mounts[subvolume], '??', False))
            continue

        snapshot = f'{snapshot}/{now}'
        if os.path.exists(snapshot):
            volumes.append((subvolume, mounts[subvolume], snapshot, True))
            continue

        volumes.append((subvolume, mounts[subvolume], snapshot, False))
    return volumes

param = sys.argv[1]

if param == 'list':
    vols = check()
    print('{0:<16}{1:<24}{2:<40}{3}'.format('Subvolume', 'Path', 'Snapshot', 'Current'))
    for vol in vols:
        print(f'{vol[0]:<16}{vol[1]:<24}{vol[2]:<40}{vol[3]}')
else:
    fatal(f'Unrecognized argument: {param}')
