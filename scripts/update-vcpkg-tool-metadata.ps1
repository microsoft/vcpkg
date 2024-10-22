[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Date
)

[string]$metadata = "VCPKG_TOOL_RELEASE_TAG=$Date`n"
Set-Content -LiteralPath "$PSScriptRoot\vcpkg-tool-metadata.txt" -Value $metadata -NoNewline -Encoding utf8NoBOM
& "$PSScriptRoot\bootstrap.ps1"
[string]$vcpkg = "$PSScriptRoot\..\vcpkg.exe"

# Windows arm64 (VS Code only)
& $vcpkg x-download "$PSScriptRoot\vcpkg-arm64.exe" `
    "--url=https://github.com/microsoft/vcpkg-tool/releases/download/$Date/vcpkg-arm64.exe" --skip-sha512

# Linux Binaries
foreach ($binary in @('macos', 'muslc', 'glibc')) {
    $caps = $binary.ToUpperInvariant()
    & $vcpkg x-download "$PSScriptRoot\vcpkg-$binary" `
      "--url=https://github.com/microsoft/vcpkg-tool/releases/download/$Date/vcpkg-$binary" --skip-sha512
    $sha512 = & $vcpkg hash "$PSScriptRoot\vcpkg-$binary"
    $metadata += "VCPKG_$($caps)_SHA=$sha512`n"
}

# Source
$sourceName = "$Date.tar.gz"
& $vcpkg x-download "$PSScriptRoot\$sourceName" `
    "--url=https://github.com/microsoft/vcpkg-tool/archive/refs/tags/$Date.tar.gz" --skip-sha512
$sha512 = & $vcpkg hash "$PSScriptRoot\$sourceName"
$metadata += "VCPKG_TOOL_SOURCE_SHA=$sha512`n"

# Cleanup
Remove-Item @(
    "$PSScriptRoot\vcpkg-arm64.exe",
    "$PSScriptRoot\vcpkg-macos",
    "$PSScriptRoot\vcpkg-muslc",
    "$PSScriptRoot\vcpkg-glibc",
    "$PSScriptRoot\$sourceName"
)

Set-Content -LiteralPath "$PSScriptRoot\vcpkg-tool-metadata.txt" -Value $metadata -NoNewline -Encoding utf8NoBOM

Write-Host "Metadata Written"
