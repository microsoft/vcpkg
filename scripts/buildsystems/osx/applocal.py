#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
finish the job started by macdeployqtfix
from: https://github.com/arl/macdeployqtfix

The MIT License (MIT)

Copyright (c) 2015 Aurelien Rainone

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

"""

from subprocess import Popen, PIPE
from string import Template
import os
import sys
import logging
import argparse
import re
from collections import namedtuple


QTLIB_NAME_REGEX = r'^(?:@executable_path)?/.*/(Qt[a-zA-Z]*).framework/(?:Versions/\d/)?\1$'
QTLIB_NORMALIZED = r'$prefix/Frameworks/$qtlib.framework/Versions/$qtversion/$qtlib'

QTPLUGIN_NAME_REGEX = r'^(?:@executable_path)?/.*/[pP]lug[iI]ns/(.*)/(.*).dylib$'
QTPLUGIN_NORMALIZED = r'$prefix/PlugIns/$plugintype/$pluginname.dylib'

LOADERPATH_REGEX = r'^@[a-z_]+path/(.*)'
LOADERPATH_NORMALIZED = r'$prefix/Frameworks/$loaderpathlib'


class GlobalConfig(object):
    logger = None
    qtpath = None
    exepath = None


def run_and_get_output(popen_args):
    """Run process and get all output"""
    process_output = namedtuple('ProcessOutput', ['stdout', 'stderr', 'retcode'])
    try:
        GlobalConfig.logger.debug('run_and_get_output({0})'.format(repr(popen_args)))

        proc = Popen(popen_args, stdin=PIPE, stdout=PIPE, stderr=PIPE)
        stdout, stderr = proc.communicate(b'')
        proc_out = process_output(stdout, stderr, proc.returncode)

        GlobalConfig.logger.debug('\tprocess_output: {0}'.format(proc_out))
        return proc_out
    except Exception as exc:
        GlobalConfig.logger.error('\texception: {0}'.format(exc))
        return process_output('', exc.message, -1)


def get_dependencies(filename):
    """
    input: filename must be an absolute path
    Should call `otool` and returns the list of dependencies, unsorted,
    unmodified, just the raw list so then we could eventually re-use in other
    more specialized functions
    """
    GlobalConfig.logger.debug('get_dependencies({0})'.format(filename))
    popen_args = ['otool', '-L', filename]
    proc_out = run_and_get_output(popen_args)
    deps = []
    if proc_out.retcode == 0:
        # some string splitting
        deps = [s.strip().split(b' ')[0].decode('utf-8') for s in proc_out.stdout.splitlines()[1:] if s]
        # prevent infinite recursion when a binary depends on itself (seen with QtWidgets)...
        deps = [s for s in deps if os.path.basename(filename) not in s]
    return deps


def is_qt_plugin(filename):
    """
    Checks if a given file is a qt plugin.
    Accepts absolute path as well as path containing @executable_path
    """
    qtlib_name_rgx = re.compile(QTPLUGIN_NAME_REGEX)
    return qtlib_name_rgx.match(filename) is not None


def is_qt_lib(filename):
    """
    Checks if a given file is a qt library.
    Accepts absolute path as well as path containing @executable_path
    """
    qtlib_name_rgx = re.compile(QTLIB_NAME_REGEX)
    return qtlib_name_rgx.match(filename) is not None


def is_loader_path_lib(filename):
    """
    Checks if a given file is loaded via @loader_path or @rpath
    """
    qtlib_name_rgx = re.compile(LOADERPATH_REGEX)
    return qtlib_name_rgx.match(filename) is not None


def normalize_qtplugin_name(filename):
    """
    input: a path to a qt plugin, as returned by otool, that can have this form :
            - an absolute path /../plugins/PLUGINTYPE/PLUGINNAME.dylib
            - @executable_path/../plugins/PLUGINTYPE/PLUGINNAME.dylib
    output:
        a tuple (qtlib, abspath, rpath) where:
            - qtname is the name of the plugin (libqcocoa.dylib, etc.)
            - abspath is the absolute path of the qt lib inside the app bundle of exepath
            - relpath is the correct rpath to a qt lib inside the app bundle
    """

    GlobalConfig.logger.debug('normalize_plugin_name({0})'.format(filename))

    qtplugin_name_rgx = re.compile(QTPLUGIN_NAME_REGEX)
    rgxret = qtplugin_name_rgx.match(filename)
    if not rgxret:
        msg = 'couldn\'t normalize a non-qt plugin filename: {0}'.format(filename)
        GlobalConfig.logger.critical(msg)
        raise Exception(msg)

    # qtplugin normalization settings
    qtplugintype = rgxret.groups()[0]
    qtpluginname = rgxret.groups()[1]

    templ = Template(QTPLUGIN_NORMALIZED)

    # from qtlib, forge 2 path :
    #  - absolute path of qt lib in bundle,
    abspath = os.path.normpath(templ.safe_substitute(
        prefix=os.path.dirname(GlobalConfig.exepath) + '/..',
        plugintype=qtplugintype,
        pluginname=qtpluginname))

    #  - and rpath containing @executable_path, relative to exepath
    rpath = templ.safe_substitute(
        prefix='@executable_path/..',
        plugintype=qtplugintype,
        pluginname=qtpluginname)

    GlobalConfig.logger.debug('\treturns({0})'.format((qtpluginname, abspath, rpath)))
    return qtpluginname, abspath, rpath


def normalize_qtlib_name(filename):
    """
    input: a path to a qt library, as returned by otool, that can have this form :
            - an absolute path /lib/xxx/yyy
            - @executable_path/../Frameworks/QtSerialPort.framework/Versions/5/QtSerialPort
    output:
        a tuple (qtlib, abspath, rpath) where:
            - qtlib is the name of the qtlib (QtCore, QtWidgets, etc.)
            - abspath is the absolute path of the qt lib inside the app bundle of exepath
            - relpath is the correct rpath to a qt lib inside the app bundle
    """
    GlobalConfig.logger.debug('normalize_qtlib_name({0})'.format(filename))

    qtlib_name_rgx = re.compile(QTLIB_NAME_REGEX)
    rgxret = qtlib_name_rgx.match(filename)
    if not rgxret:
        msg = 'couldn\'t normalize a non-qt lib filename: {0}'.format(filename)
        GlobalConfig.logger.critical(msg)
        raise Exception(msg)

    # qtlib normalization settings
    qtlib = rgxret.groups()[0]
    qtversion = 5

    templ = Template(QTLIB_NORMALIZED)

    # from qtlib, forge 2 path :
    #  - absolute path of qt lib in bundle,
    abspath = os.path.normpath(templ.safe_substitute(
        prefix=os.path.dirname(GlobalConfig.exepath) + '/..',
        qtlib=qtlib,
        qtversion=qtversion))

    #  - and rpath containing @executable_path, relative to exepath
    rpath = templ.safe_substitute(
        prefix='@executable_path/..',
        qtlib=qtlib,
        qtversion=qtversion)

    GlobalConfig.logger.debug('\treturns({0})'.format((qtlib, abspath, rpath)))
    return qtlib, abspath, rpath


def normalize_loaderpath_name(filename):
    """
    input: a path to a loaderpath library, as returned by otool, that can have this form :
            - an relative path @loaderpath/yyy
    output:
        a tuple (loaderpathlib, abspath, rpath) where:
            - loaderpathlib is the name of the loaderpath lib
            - abspath is the absolute path of the qt lib inside the app bundle of exepath
            - relpath is the correct rpath to a qt lib inside the app bundle
    """
    GlobalConfig.logger.debug('normalize_loaderpath_name({0})'.format(filename))

    loaderpath_name_rgx = re.compile(LOADERPATH_REGEX)
    rgxret = loaderpath_name_rgx.match(filename)
    if not rgxret:
        msg = 'couldn\'t normalize a loaderpath lib filename: {0}'.format(filename)
        GlobalConfig.logger.critical(msg)
        raise Exception(msg)

    # loaderpath normalization settings
    loaderpathlib = rgxret.groups()[0]
    templ = Template(LOADERPATH_NORMALIZED)

    # from loaderpath, forge 2 path :
    #  - absolute path of qt lib in bundle,
    abspath = os.path.normpath(templ.safe_substitute(
        prefix=os.path.dirname(GlobalConfig.exepath) + '/..',
        loaderpathlib=loaderpathlib))

    #  - and rpath containing @executable_path, relative to exepath
    rpath = templ.safe_substitute(
        prefix='@executable_path/..',
        loaderpathlib=loaderpathlib)

    GlobalConfig.logger.debug('\treturns({0})'.format((loaderpathlib, abspath, rpath)))
    return loaderpathlib, abspath, rpath


def fix_dependency(binary, dep):
    """
    fix 'dep' dependency of 'binary'. 'dep' is a qt library
    """
    if is_qt_lib(dep):
        qtname, dep_abspath, dep_rpath = normalize_qtlib_name(dep)
        qtnamesrc = os.path.join(GlobalConfig.qtpath, 'lib', '{0}.framework'.
                                 format(qtname), qtname)
    elif is_qt_plugin(dep):
        qtname, dep_abspath, dep_rpath = normalize_qtplugin_name(dep)
        qtnamesrc = os.path.join(GlobalConfig.qtpath, 'lib', '{0}.framework'.
                                 format(qtname), qtname)
    elif is_loader_path_lib(dep):
        qtname, dep_abspath, dep_rpath = normalize_loaderpath_name(dep)
        qtnamesrc = os.path.join(GlobalConfig.qtpath + '/lib', qtname)
    else:
        return True

    # if the source path doesn't exist it's probably not a dependency
    # originating with vcpkg and we should leave it alone
    if not os.path.exists(qtnamesrc):
        return True

    dep_ok = True
    # check that rpath of 'dep' inside binary has been correctly set
    # (ie: relative to exepath using '@executable_path' syntax)
    if dep != dep_rpath:
        # dep rpath is not ok
        GlobalConfig.logger.info('changing rpath \'{0}\' in binary {1}'.format(dep, binary))

        # call install_name_tool -change on binary
        popen_args = ['install_name_tool', '-change', dep, dep_rpath, binary]
        proc_out = run_and_get_output(popen_args)
        if proc_out.retcode != 0:
            GlobalConfig.logger.error(proc_out.stderr)
            dep_ok = False
        else:
            # call install_name_tool -id on binary
            popen_args = ['install_name_tool', '-id', dep_rpath, binary]
            proc_out = run_and_get_output(popen_args)
            if proc_out.retcode != 0:
                GlobalConfig.logger.error(proc_out.stderr)
                dep_ok = False

    # now ensure that 'dep' exists at the specified path, relative to bundle
    if dep_ok and not os.path.exists(dep_abspath):

        # ensure destination directory exists
        GlobalConfig.logger.info('ensuring directory \'{0}\' exists: {0}'.
                                 format(os.path.dirname(dep_abspath)))
        popen_args = ['mkdir', '-p', os.path.dirname(dep_abspath)]
        proc_out = run_and_get_output(popen_args)
        if proc_out.retcode != 0:
            GlobalConfig.logger.info(proc_out.stderr)
            dep_ok = False
        else:
            # copy missing dependency into bundle
            GlobalConfig.logger.info('copying missing dependency in bundle: {0}'.
                                     format(qtname))
            popen_args = ['cp', qtnamesrc, dep_abspath]
            proc_out = run_and_get_output(popen_args)
            if proc_out.retcode != 0:
                GlobalConfig.logger.info(proc_out.stderr)
                dep_ok = False
            else:
                # ensure permissions are correct if we ever have to change its rpath
                GlobalConfig.logger.info('ensuring 755 perm to {0}'.format(dep_abspath))
                popen_args = ['chmod', '755', dep_abspath]
                proc_out = run_and_get_output(popen_args)
                if proc_out.retcode != 0:
                    GlobalConfig.logger.info(proc_out.stderr)
                    dep_ok = False
    else:
        GlobalConfig.logger.debug('{0} is at correct location in bundle'.format(qtname))

    if dep_ok:
        return fix_binary(dep_abspath)
    return False


def fix_binary(binary):
    """
        input:
          binary: relative or absolute path (no @executable_path syntax)
        process:
        - first fix the rpath for the qt libs on which 'binary' depend
        - copy into the bundle of exepath the eventual libraries that are missing
        - (create the soft links) needed ?
        - do the same for all qt dependencies of binary (recursive)
    """
    GlobalConfig.logger.debug('fix_binary({0})'.format(binary))

    # loop on 'binary' dependencies
    for dep in get_dependencies(binary):
        if not fix_dependency(binary, dep):
            GlobalConfig.logger.error('quitting early: couldn\'t fix dependency {0} of {1}'.format(dep, binary))
            return False
    return True


def fix_main_binaries():
    """
        list the main binaries of the app bundle and fix them
    """
    # deduce bundle path
    bundlepath = os.path.sep.join(GlobalConfig.exepath.split(os.path.sep)[0:-3])

    # fix main binary
    GlobalConfig.logger.info('fixing executable \'{0}\''.format(GlobalConfig.exepath))
    if fix_binary(GlobalConfig.exepath):
        GlobalConfig.logger.info('fixing plugins')
        for root, dummy, files in os.walk(bundlepath):
            for name in [f for f in files if os.path.splitext(f)[1] == '.dylib']:
                GlobalConfig.logger.info('fixing plugin {0}'.format(name))
                if not fix_binary(os.path.join(root, name)):
                    return False
    return True


def main():
    descr = """finish the job started by macdeployqt!
 - find dependencies/rpaths with otool
 - copy missed dependencies with cp and mkdir
 - fix missed rpaths        with install_name_tool

 exit codes:
 - 0 : success
 - 1 : error
 """

    parser = argparse.ArgumentParser(description=descr,
                                     formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('exepath',
                        help='path to the binary depending on Qt')
    parser.add_argument('qtpath',
                        help='path of Qt libraries used to build the Qt application')
    parser.add_argument('-q', '--quiet', action='store_true', default=False,
                        help='do not create log on standard output')
    parser.add_argument('-nl', '--no-log-file', action='store_true', default=False,
                        help='do not create log file \'./macdeployqtfix.log\'')
    parser.add_argument('-v', '--verbose', action='store_true', default=False,
                        help='produce more log messages(debug log)')
    args = parser.parse_args()

    # globals
    GlobalConfig.qtpath = os.path.normpath(args.qtpath)
    GlobalConfig.exepath = args.exepath
    GlobalConfig.logger = logging.getLogger()

    # configure logging
    ###################

    # create formatter
    formatter = logging.Formatter('%(levelname)s | %(message)s')
    # create console GlobalConfig.logger
    if not args.quiet:
        chdlr = logging.StreamHandler(sys.stdout)
        chdlr.setFormatter(formatter)
        GlobalConfig.logger.addHandler(chdlr)

    # create file GlobalConfig.logger
    if not args.no_log_file:
        fhdlr = logging.FileHandler('./macdeployqtfix.log', mode='w')
        fhdlr.setFormatter(formatter)
        GlobalConfig.logger.addHandler(fhdlr)

    if args.no_log_file and args.quiet:
        GlobalConfig.logger.addHandler(logging.NullHandler())
    else:
        GlobalConfig.logger.setLevel(logging.DEBUG if args.verbose else logging.INFO)

    if fix_main_binaries():
        GlobalConfig.logger.info('macdeployqtfix terminated with success')
        ret = 0
    else:
        GlobalConfig.logger.error('macdeployqtfix terminated with error')
        ret = 1
    sys.exit(ret)


if __name__ == "__main__":
    main()
