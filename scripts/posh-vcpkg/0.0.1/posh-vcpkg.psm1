param()

if (Get-Module posh-vcpkg) { return }

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Warning ("posh-vcpkg does not support PowerShell versions before 5.0.")
    return
}

if (Test-Path Function:\TabExpansion) {
    Rename-Item Function:\TabExpansion VcpkgTabExpansionBackup
}

function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()

    switch -regex ($lastBlock) {
        "^(?<vcpkgexe>(\./|\.\\|)vcpkg(\.exe|)) (?<remaining>.*)$"
        {
            & $matches['vcpkgexe'] autocomplete $matches['remaining']
            return
        }

        # Fall back on existing tab expansion
        default {
            if (Test-Path Function:\VcpkgTabExpansionBackup) {
                VcpkgTabExpansionBackup $line $lastWord
            }
        }
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'TabExpansion'
    )
}

Export-ModuleMember @exportModuleMemberParams
