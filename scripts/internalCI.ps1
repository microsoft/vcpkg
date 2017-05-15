$ErrorActionPreference = "Stop"

New-Item -type directory downloads -errorAction SilentlyContinue | Out-Null
New-Item -type file downloads\AlwaysAllowDownloads -errorAction SilentlyContinue | Out-Null
./scripts/bootstrap.ps1
if (-not $?) { exit $? }

# Clear out any intermediate files from the previous build
Get-ChildItem buildtrees/*/* | ? Name -ne "src" | Remove-Item -Recurse -Force

# Purge any outdated packages
./vcpkg remove --outdated --recurse
if (-not $?) { exit $? }

./vcpkg.exe install azure-storage-cpp cpprestsdk:x64-windows-static cpprestsdk:x86-uwp
if (-not $?) { exit $? }

./vcpkg.exe install bond chakracore cryptopp zlib expat sdl2 curl sqlite3 libuv protobuf:x64-windows sfml opencv:x64-windows
if (-not $?) { exit $? }

./vcpkg.exe install opencv:x86-uwp boost:x86-uwp
if (-not $?) { exit $? }

./vcpkg.exe install folly:x64-windows
if (-not $?) { exit $? }
