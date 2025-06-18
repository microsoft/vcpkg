#!/bin/sh
set -e

git clone --depth 1 https://github.com/microsoft/vcpkg-tool vcpkg-tool
git -C vcpkg-tool fetch --depth 1 origin $1
git -C vcpkg-tool switch -d FETCH_HEAD
rm -rf build.x64.release
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DVCPKG_DEVELOPMENT_WARNINGS=OFF -DVCPKG_WARNINGS_AS_ERRORS=OFF -DVCPKG_BUILD_FUZZING=OFF -DVCPKG_BUILD_TLS12_DOWNLOADER=OFF -B build.x64.release -S vcpkg-tool
ninja -C build.x64.release
mv build.x64.release/vcpkg vcpkg
