call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" -arch=x86 -host_arch=x86
git clone --depth 1 https://github.com/microsoft/vcpkg-tool vcpkg-tool
git -C vcpkg-tool fetch --depth 1 origin %1
git -C vcpkg-tool switch -d FETCH_HEAD
rmdir /s /q build.x86.release > nul 2> nul
cmake.exe -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DVCPKG_DEVELOPMENT_WARNINGS=OFF -DVCPKG_WARNINGS_AS_ERRORS=OFF -DVCPKG_BUILD_FUZZING=OFF -DVCPKG_BUILD_TLS12_DOWNLOADER=OFF -B build.x86.release -S vcpkg-tool
ninja.exe -C build.x86.release
move build.x86.release\vcpkg.exe vcpkg.exe
