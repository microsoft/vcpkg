#!/bin/sh -e

vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
unixName=$(uname -s)
if [[ $unixName == MINGW*_NT* ]]; then
  vcpkgRootDir=$(cygpath -aw "$vcpkgRootDir")
  cmd "/C $vcpkgRootDir\\bootstrap-vcpkg.bat"
else
  . "$vcpkgRootDir/scripts/bootstrap.sh"
fi
