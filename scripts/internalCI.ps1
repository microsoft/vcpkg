$ErrorActionPreference = "Stop"

New-Item -type directory downloads -errorAction SilentlyContinue | Out-Null
./scripts/bootstrap.ps1
if (-not $?) { throw $? }

# Clear out any intermediate files from the previous build
Get-ChildItem buildtrees/*/* | ? { $_.Name -ne "src" -and $_.Extension -ne ".log"} | Remove-Item -Recurse -Force

# Purge any outdated packages
./vcpkg remove --outdated --recurse
if (-not $?) { throw $? }

./vcpkg.exe install azure-storage-cpp cpprestsdk:x64-windows-static cpprestsdk:x86-uwp
if (-not $?) { throw $? }

./vcpkg.exe install bond cryptopp zlib expat sdl2 curl sqlite3 libuv protobuf:x64-windows sfml opencv:x64-windows uwebsockets uwebsockets:x64-windows-static
if (-not $?) { throw $? }

./vcpkg.exe install opencv:x86-uwp boost:x86-uwp
if (-not $?) { throw $? }

# ./vcpkg.exe install folly:x64-windows
# if (-not $?) { throw $? }
