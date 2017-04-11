$ErrorActionPreference = "Stop"

If (Test-Path vcpkg.exe) {
	echo "Removing vcpkg.exe..."
	Remove-Item vcpkg.exe -force
}

If (Test-Path buildtrees) {
	echo "Removing buildtrees..."
	Remove-Item buildtrees -recurse -force
}

If (Test-Path packages) {
	echo "Removing packages..."
	Remove-Item packages -recurse -force
}

If (Test-Path installed) {
	echo "Removing installed..."
	Remove-Item installed -recurse -force
}
