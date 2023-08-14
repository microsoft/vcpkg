[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Date
)

function Get-Sha256 {
    Param([string]$File)
    $content = [System.IO.File]::ReadAllBytes($File)
    $shaHasher = $null
    [string]$shaHash = ''
    try {
        $shaHasher = [System.Security.Cryptography.SHA256]::Create()
        $hashBytes = $shaHasher.ComputeHash($content)
        $shaHash = [System.BitConverter]::ToString($hashBytes).Replace('-', '').ToLowerInvariant()
    } finally {
        if ($shaHasher -ne $null) {
            $shaHasher.Dispose();
        }
    }

    return $shaHash
}

[string]$metadata = "VCPKG_TOOL_RELEASE_TAG=$Date`n"
$vsCodeHashes = [ordered]@{}
Set-Content -LiteralPath "$PSScriptRoot\vcpkg-tool-metadata.txt" -Value $metadata -NoNewline -Encoding utf8NoBOM
& "$PSScriptRoot\bootstrap.ps1"
[string]$vcpkg = "$PSScriptRoot\..\vcpkg.exe"

# Windows arm64 (VS Code only)
& $vcpkg x-download "$PSScriptRoot\vcpkg-arm64.exe" `
    "--url=https://github.com/microsoft/vcpkg-tool/releases/download/$Date/vcpkg-arm64.exe" --skip-sha512
$vsCodeHashes["vcpkg-arm64.exe"] = Get-Sha256 "$PSScriptRoot\vcpkg-arm64.exe"

# Linux Binaries
foreach ($binary in @('macos', 'muslc', 'glibc')) {
    $caps = $binary.ToUpperInvariant()
    & $vcpkg x-download "$PSScriptRoot\vcpkg-$binary" `
      "--url=https://github.com/microsoft/vcpkg-tool/releases/download/$Date/vcpkg-$binary" --skip-sha512
    $sha512 = & $vcpkg hash "$PSScriptRoot\vcpkg-$binary"
    $metadata += "VCPKG_$($caps)_SHA=$sha512`n"
    $vsCodeHashes["vcpkg-$binary"] = Get-Sha256 "$PSScriptRoot\vcpkg-$binary"
}

# Windows x64 (assumed to be host)
$vsCodeHashes["vcpkg.exe"] = Get-Sha256 "$vcpkg"

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
Write-Host "VS Code Block"
$vsCodeOverall = [ordered]@{
    version = $Date;
    hashes = $vsCodeHashes;
}

Write-Host (ConvertTo-Json $vsCodeOverall)
