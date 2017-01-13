$ErrorActionPreference = "Stop"

if (!(Test-Path vcpkg.exe)) { 
	scripts\bootstrap.ps1
	if ($LastExitCode -ne 0) { throw }
}

./vcpkg.exe install `
	boost:x86-windows-static `
	civetweb:x86-windows-static `
	fmt:x86-windows-static `
	gtest:x86-windows-static `
	hiredis:x86-windows-static `
	json-c:x86-windows-static `
	libevent:x86-windows-static `
	lua51:x86-windows-static `
	lua-intf:x86-windows-static `
	pion:x86-windows-static `
	protobuf:x86-windows-static `
	rapidxml:x86-windows-static `
	snmp-pp:x86-windows-static `
	sqlite3:x86-windows-static `
	zlib:x86-windows-static
if ($LastExitCode -ne 0) { throw }

# update the version anytime the installed package versions change
Write-Output 1 > installed/version.txt
