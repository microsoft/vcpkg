. "$PSScriptRoot/../end-to-end-tests-prelude.ps1"


$commonArgs += @("--x-builtin-port-versions-dir=$PSScriptRoot/../../e2e_ports/port_versions")

Run-Vcpkg install @commonArgs 'vcpkg-internal-e2e-test-port'
Throw-IfNotFailed

Run-Vcpkg install @commonArgs --feature-flags=registries 'vcpkg-internal-e2e-test-port'
Throw-IfFailed

Run-Vcpkg install @commonArgs --feature-flags=registries 'zlib'
Throw-IfFailed
