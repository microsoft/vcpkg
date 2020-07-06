#!/usr/bin/python

import argparse
import errno
import os
import re
import shutil
import subprocess
import sys
import tempfile
import logging

SUPPORTED_TARGETS = {'armv7-a': 'arm',
                     'aarch64': 'arm64',
                     'i686': 'x86',
                     'x86_64': 'x64'}
SUPPORTED_CONFIGS = ('Debug', 'Release')

# change default ndk
# default_android_ndk_root = "/path/to/android_ndk"
# default_android_ndk_version = "r21"
# default_android_ndk_major_version = 21


class Builder(object):
    def __init__(self, root, build, install):
        self._root = root
        self._build_dir = build
        self._install_dir = install

    def _Gen(self, target, config):
        gn_path = FindCommand('gn')
        assert gn_path != None

        target_name = 'Android-{}-{}'.format(target, config)
        target_out = os.path.join(self._build_dir, target_name)

        command = [gn_path]
        command.append('gen')
        command.append(target_out)
        command.append('--args="')
        command.append('is_component_build=true')
        command.append('is_debug={}'.format(
            'true' if config == 'Debug' else 'false'))
        command.append('target_os=\\"android\\"')
        command.append('target_cpu=\\"{}\\"'.format(SUPPORTED_TARGETS[target]))
        if config == 'Release':
            command.append('symbol_level=0')
        command.append('"')

        cmd = ' '.join(command)
        logging.info("Gen args : [{}]".format(cmd))
        proc = subprocess.Popen(cmd, cwd=self._root, shell=True)
        proc.wait()

        if proc.returncode != 0:
            return None
        return target_out

    def _Build(self, out, chromium_target='base'):
        ninja_path = FindCommand('ninja')
        assert ninja_path != None

        command = [ninja_path]
        command.append('-C')
        command.append(out)
        command.append(chromium_target)

        cmd = ' '.join(command)
        logging.info("Build args : [{}]".format(cmd))
        proc = subprocess.Popen(cmd, cwd=self._root, shell=True)
        proc.wait()

        return True if proc.returncode == 0 else False

    def Build(self):
        for config in SUPPORTED_CONFIGS:
            for target in SUPPORTED_TARGETS:
                target_out = self._Gen(target, config)
                target_name = os.path.basename(target_out)
                if target_out != None and self._Build(target_out):
                    dest = os.path.join(self._install_dir, target_name)
                    logging.info(
                        "Copy files from {} to {}".format(target_out, dest))
                    CopyFiles(target_out, dest,
                              filter=['args.gn', '.h', '.so', '.TOC'])


def FindCommand(cmd):
    '''Returns absolute path to gn binary looking at the PATH env variable.'''
    for path in os.environ['PATH'].split(os.path.pathsep):
        cmd_path = os.path.join(path, cmd)
        if os.path.isfile(cmd_path) and os.access(cmd_path, os.X_OK):
            return cmd_path
    return None


def CopyFiles(srcdir, dstdir,
              filter=['.h', '.a', '.so', '.dylib', '.TOC', '.dll', '.lib'],
              exclude=['obj']):
    paths = os.listdir(srcdir)
    for path in paths:
        if exclude and path in exclude:
            continue
        if os.path.isdir(os.path.join(srcdir, path)):
            CopyFiles(os.path.join(srcdir, path),
                      os.path.join(dstdir, path),
                      filter,
                      exclude)
        elif os.path.isfile(os.path.join(srcdir, path)):
            ext = os.path.splitext(os.path.join(srcdir, path))[1]
            if (filter != None) and (ext not in filter) and (path not in filter):
                continue
            if not os.path.exists(dstdir):
                os.makedirs(dstdir)
            shutil.copy(os.path.join(srcdir, path), dstdir)


def Main(args):
    logging.basicConfig(level=logging.INFO)
    default_root = os.path.abspath(os.path.join(
        os.path.dirname(__file__), os.pardir, 'src'))
    install_dir = os.path.abspath(os.path.join(default_root, os.pardir, 'out'))

    parser = argparse.ArgumentParser(
        description='Build for Android')
    parser.add_argument(
        'root', default=default_root, nargs='?',
        help='root directory where to generate multiple out configurations')
    parser.add_argument(
        'install', default=install_dir, nargs='?',
        help='root directory where to generate multiple out configurations')
    args = parser.parse_args(args)

    build_dir = os.path.join(args.root, 'out')
    if not os.path.isdir(build_dir):
        os.makedirs(build_dir)

    builder = Builder(args.root, build_dir, args.install)
    builder.Build()


if __name__ == '__main__':
    sys.exit(Main(sys.argv[1:]))
