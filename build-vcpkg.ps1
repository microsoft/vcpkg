$ErrorActionPreference = "Stop"

function Invoke-VcpkgBuild($pkg) {
	.\vcpkg.exe install $pkg`:x64-windows-mixed --vcpkg-root .
	if ($LastExitCode -ne 0) { throw }
}

if (!(Test-Path vcpkg.exe)) { 
	scripts\bootstrap.ps1 -disableMetrics
	if ($LastExitCode -ne 0) { throw }
}

Invoke-VcpkgBuild "zlib"
Invoke-VcpkgBuild "sqlite3"
Invoke-VcpkgBuild "boost-circular-buffer"
Invoke-VcpkgBuild "boost-random"
Invoke-VcpkgBuild "boost-filesystem"
Invoke-VcpkgBuild "boost-asio"
Invoke-VcpkgBuild "boost-geometry"
Invoke-VcpkgBuild "boost-qvm"
Invoke-VcpkgBuild "fmt"
Invoke-VcpkgBuild "spdlog"
Invoke-VcpkgBuild "nlohmann-json"
Invoke-VcpkgBuild "json-c"
Invoke-VcpkgBuild "luajit"
Invoke-VcpkgBuild "lua-intf"
Invoke-VcpkgBuild "rapidxml"
Invoke-VcpkgBuild "libevent"
Invoke-VcpkgBuild "hiredis"
Invoke-VcpkgBuild "protobuf"
Invoke-VcpkgBuild "pthreads"
Invoke-VcpkgBuild "websocketpp"
Invoke-VcpkgBuild "curl"
Invoke-VcpkgBuild "gtest"

# export created libraries and set version
.\vcpkg.exe export --x-all-installed --raw --vcpkg-root .
Move-Item -Path .\vcpkg-export-* -Destination .\vcpkg
Write-Output 16 > vcpkg\installed\version.txt
