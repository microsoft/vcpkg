$ErrorActionPreference = "Stop"

function Invoke-VcpkgBuild($pkg) {
	.\vcpkg.exe install $pkg`:x86-windows-mixed
	if ($LastExitCode -ne 0) { throw }
}

if (!(Test-Path vcpkg.exe)) { 
	scripts\bootstrap.ps1
	if ($LastExitCode -ne 0) { throw }
}

Invoke-VcpkgBuild "gtest"
Invoke-VcpkgBuild "zlib"
Invoke-VcpkgBuild "sqlite3"
Invoke-VcpkgBuild "boost"
Invoke-VcpkgBuild "fmt"
Invoke-VcpkgBuild "hiredis"
Invoke-VcpkgBuild "json-c"
Invoke-VcpkgBuild "libevent"
Invoke-VcpkgBuild "luajit"
Invoke-VcpkgBuild "lua-lsqlite3"
Invoke-VcpkgBuild "lua-intf"
Invoke-VcpkgBuild "rapidxml"
Invoke-VcpkgBuild "snmp-pp"
Invoke-VcpkgBuild "pthread"
Invoke-VcpkgBuild "websocketpp"

# update the version anytime the installed package versions change
Write-Output 5 > installed/version.txt
