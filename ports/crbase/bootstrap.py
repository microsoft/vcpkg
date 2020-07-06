#!/usr/bin/env python
# coding=utf-8

__author__ = "huahua"

import os
import sys
import shutil
import logging
import platform
import subprocess
import collections

Root = os.path.dirname(os.path.realpath(__file__))
ChromiumGit = "https://chromium.googlesource.com/chromium/src.git"
ChromiumTag = "78.0.3904.130"
ChromiumCommitTag = "e4745133a1d3745f066e068b8033c6a269b59caf"
ChromiumCommitCheckout = "c1109b707b1eda5d98eb2ed6bd74083bc352f482"
ChromiumPath = os.path.join(Root, 'src')
SystemSupported = ['Windows', 'Linux', 'Darwin']

VersionInfo = collections.namedtuple("VersionInfo",
                                     ("revision_id", "revision", "timestamp"))

BuildType = ['Debug', 'Release']
AndroidCpuMap = [
    ['arm64', 'aarch64'],
    ['arm', 'armv7-a'],
    ['x86', 'i686'],
    ['x64', 'x86_64'],
]


class GitError(Exception):
    pass


def RunCommand(directory, command, is_shell=(sys.platform == 'win32')):
    proc = subprocess.Popen(command, cwd=directory, shell=is_shell)
    proc.wait()
    return proc


def RunGitCommand(directory, command):
    command = ['git'] + command
    if sys.platform == 'cygwin':
        command = ['sh', '-c', ' '.join(command)]
    try:
        proc = subprocess.Popen(command,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE,
                                cwd=directory,
                                shell=(sys.platform == 'win32'))
        proc.wait()
        return proc
    except BaseException as e:
        logging.error('Command %r failed: %s' % (' '.join(command), e))
        return None


def _RunGitCommand(directory, command):
    """Launches git subcommand.

    Returns:
      The stripped stdout of the git command.
    Raises:
      GitError on failure, including a nonzero return code.
    """
    command = ['git'] + command
    # Force shell usage under cygwin. This is a workaround for
    # mysterious loss of cwd while invoking cygwin's git.
    # We can't just pass shell=True to Popen, as under win32 this will
    # cause CMD to be used, while we explicitly want a cygwin shell.
    if sys.platform == 'cygwin':
        command = ['sh', '-c', ' '.join(command)]
    try:
        logging.info("Executing '%s' in %s", ' '.join(command), directory)
        proc = subprocess.Popen(command,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE,
                                cwd=directory,
                                shell=(sys.platform == 'win32'))
        stdout, stderr = tuple(x.decode(encoding='utf_8')
                               for x in proc.communicate())
        stdout = stdout.strip()
        if proc.returncode != 0 or stderr:
            raise GitError((
                "Git command '{}' in {} failed: returncode={}"
                "stdout='{}'\nstderr='{}'").format(
                " ".join(command), directory, proc.returncode, stdout, stderr))
        return stdout
    except OSError as e:
        raise GitError("Git command 'git {}' in {} failed: {}".format(
            " ".join(command), directory, e))


def FetchGitRevision(directory, commit_filter, start_commit="HEAD"):
    """
    Fetch the Git hash (and Cr-Commit-Position if any) for a given directory.

    Args:
      directory: The directory containing the .git directory.
      commit_filter: A filter to supply to grep to filter commits
      start_commit: A commit identifier. The result of this function
        will be limited to only consider commits before the provided
        commit.
    Returns:
      A VersionInfo object. On error all values will be 0.
    """
    hash_ = ''

    git_args = ['log', '-1', '--format=%H %ct']
    if commit_filter is not None:
        git_args.append('--grep=' + commit_filter)

    git_args.append(start_commit)

    output = _RunGitCommand(directory, git_args)
    hash_, commit_timestamp = output.split()
    if not hash_:
        return VersionInfo('0', '0', 0)

    revision = hash_
    output = _RunGitCommand(directory, ['cat-file', 'commit', hash_])
    for line in reversed(output.splitlines()):
        if line.startswith('Cr-Commit-Position:'):
            pos = line.rsplit()[-1].strip()
            logging.debug("Found Cr-Commit-Position '%s'", pos)
            revision = "{}-{}".format(hash_, pos)
            break
    return VersionInfo(hash_, revision, int(commit_timestamp))


def WriteIfChanged(file_name, contents):
    """
    Writes the specified contents to the specified file_name
    iff the contents are different than the current contents.
    Returns if new data was written.
    """
    try:
        old_contents = open(file_name, 'r').read()
    except EnvironmentError:
        pass
    else:
        if contents == old_contents:
            return False
        os.unlink(file_name)
    open(file_name, 'w').write(contents)
    return True


def FindGitCommit(path, commit):
    command = ['log', '-1', '--format=%H', commit]
    try:
        _RunGitCommand(path, command)
    except GitError as e:
        logging.info("Commit [%s] object no found: %s", commit, e)
        return False
    return True


def ChromiumDownload():
    command = ['git', 'clone', '--depth=2', ChromiumGit,
               '-b', ChromiumTag, ChromiumPath]
    return RunCommand(Root, command)


def ChromiumFetchTag():
    if not FindGitCommit(ChromiumPath, ChromiumCommitCheckout):
        command = ['fetch', '--depth=2', 'origin', ChromiumTag]
        _RunGitCommand(ChromiumPath, command)


def GitMisc():
    if sys.platform != 'win32':
        command = ['config' 'oh-my-zsh.hide-status' '1']
        RunGitCommand(ChromiumPath, command)


def ChromiumSwitchBranch():
    try:
        ver = FetchGitRevision(ChromiumPath, None)
        if ver.revision_id != ChromiumCommitCheckout:
            command = ['checkout', '-b', ChromiumTag, ChromiumCommitCheckout]
            return _RunGitCommand(ChromiumPath, command)
    except GitError:
        logging.error("Branch switch faild.")


def ChromiumGenGclient():
    gclient_path = os.path.join(Root, '.gclient')
    entry_path = os.path.join(Root, '.gclient_entries')
    gclient_content = """
solutions = [
  {
    "url": "https://chromium.googlesource.com/chromium/src.git",
    "managed": False,
    "name": "src",
    "custom_deps": {},
    "custom_vars": {
      "checkout_configuration": "small",
      "checkout_nacl": False,
      "checkout_openxr" : False
    },
  },
]
"""
    entry_content = """
entries = {
  'src': 'https://chromium.googlesource.com/chromium/src.git',
}
"""

    if not os.path.exists(gclient_path):
        WriteIfChanged(gclient_path, gclient_content)
    if not os.path.exists(entry_path):
        WriteIfChanged(entry_path, entry_content)


def ChromiumPatch():
    root_build_src_path = os.path.join(Root, 'scripts', 'BUILD.gn')
    root_build_dst_path = os.path.join(ChromiumPath, 'BUILD.gn')
    shutil.copyfile(root_build_src_path, root_build_dst_path)

    patch_dir = os.path.join(Root, 'scripts', 'patch')
    for patch_name in os.listdir(patch_dir):
        patch_path = os.path.join(patch_dir, patch_name)
        if patch_path.endswith('-78.patch'):
            command = ['apply', '--check', patch_path]
            if RunGitCommand(ChromiumPath, command).returncode == 0:
                command = ['apply', patch_path]
                RunGitCommand(ChromiumPath, command)


def ChromiumSync():
    command = ['gclient', 'sync', '--no-history']
    RunCommand(ChromiumPath, command)


def ChromiumBuild():
    for bt in BuildType:
        is_debug = True if bt == 'Debug' else False
        is_debug_key = 'true' if is_debug else 'false'
        symbol_level_key = 2 if is_debug else 0
        targetname = platform.system() + '-' + platform.machine() + '-' + bt
        targetdir = os.path.join('out', targetname)
        commandconfig = ['gn', 'gen', targetdir, '--args="',
                         'is_component_build=true',
                         'is_debug={}'.format(is_debug_key),
                         'symbol_level={}'.format(symbol_level_key),
                         '"']
        commandconfigline = " ".join(commandconfig)
        commandbuild = ['autoninja', '-C', targetdir, 'base']

        logging.info("----- Build for [%s] -----", targetname)
        logging.info(commandconfigline)
        if RunCommand(ChromiumPath, commandconfigline, True).returncode == 0:
            if RunCommand(ChromiumPath, commandbuild).returncode == 0:
                srcdir = os.path.join(ChromiumPath, targetdir)
                dstdir = os.path.join(Root, targetdir)
                logging.info("Build output : %s", dstdir)
                ChromiumCopyOut(srcdir, dstdir)


def ChromiumCopyOut(srcdir, dstdir,
                    filter=['.h', '.a', '.so', '.dylib',
                            '.TOC', '.dll', '.lib'],
                    exclude=['obj']):
    paths = os.listdir(srcdir)
    for path in paths:
        if exclude and path in exclude:
            continue
        if os.path.isdir(os.path.join(srcdir, path)):
            ChromiumCopyOut(os.path.join(srcdir, path),
                            os.path.join(dstdir, path),
                            filter)
        elif os.path.isfile(os.path.join(srcdir, path)):
            ext = os.path.splitext(os.path.join(srcdir, path))[1]
            if (filter != None) and (ext not in filter):
                continue
            if not os.path.exists(dstdir):
                os.makedirs(dstdir)
            shutil.copy(os.path.join(srcdir, path), dstdir)
        else:
            logging.warn("Unkhown file : %s", path)


def Bootstrap(systemname):
    logging.basicConfig(level=logging.INFO)

    if not systemname in SystemSupported:
        logging.error("Only supported system : %s", SystemSupported)
        return

    logging.info("Bootstrap for [%s]", systemname)
    if systemname == 'Windows':
        os.environ['DEPOT_TOOLS_WIN_TOOLCHAIN'] = '0'

    if not os.path.exists(ChromiumPath):
        ChromiumDownload()
    else:
        ChromiumFetchTag()

    GitMisc()
    ChromiumSwitchBranch()
    ChromiumGenGclient()
    ChromiumPatch()
    ChromiumSync()
    ChromiumBuild()


if __name__ == "__main__":
    systemname = sys.argv[1] if len(sys.argv) > 1 else platform.system()
    Bootstrap(systemname)
