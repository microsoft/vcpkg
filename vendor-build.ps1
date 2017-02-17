$ErrorActionPreference = "Stop"

if (!(Test-Path vcpkg.exe)) { 
	scripts\bootstrap.ps1
	if ($LastExitCode -ne 0) { throw }
}

./vcpkg.exe install `
	gtest:x86-windows-mixed `
	zlib:x86-windows-mixed `
	sqlite3:x86-windows-mixed `
	boost:x86-windows-mixed `
	civetweb:x86-windows-mixed `
	fmt:x86-windows-mixed `
	protobuf:x86-windows-mixed `
	hiredis:x86-windows-mixed `
	json-c:x86-windows-mixed `
	libevent:x86-windows-mixed `
	luajit:x86-windows-mixed `
	lua-lsqlite3:x86-windows-mixed `
	lua-intf:x86-windows-mixed `
	pion:x86-windows-mixed `
	rapidxml:x86-windows-mixed `
	snmp-pp:x86-windows-mixed `
	pthread:x86-windows-mixed
if ($LastExitCode -ne 0) { throw }

# update the version anytime the installed package versions change
Write-Output 2 > installed/version.txt
