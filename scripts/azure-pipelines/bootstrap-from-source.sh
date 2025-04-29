#!/bin/sh
set -e

git clone https://github.com/talregev/vcpkg-tool -b TalR/upload_by_chunks vcpkg-tool
rm -rf build.x64.release
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DVCPKG_DEVELOPMENT_WARNINGS=OFF -DVCPKG_WARNINGS_AS_ERRORS=OFF -DVCPKG_BUILD_FUZZING=OFF -DVCPKG_BUILD_TLS12_DOWNLOADER=OFF -B build.x64.release -S vcpkg-tool
ninja -C build.x64.release
mv build.x64.release/vcpkg vcpkg
