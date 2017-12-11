[CmdletBinding()]
param()

function findExistingImportModuleDirectives([Parameter(Mandatory=$true)][string]$path)
{
    if (!(Test-Path $path))
    {
        return $false
    }

    $fileContents = Get-Content $path
    return $fileContents -match 'Import-Module.+?(?=posh-vcpkg)'
}

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"

$profileEntry = "Import-Module '$scriptsDir\posh-vcpkg'"
$profilePath = $PROFILE # Implicit powershell variable
if (!(Test-Path $profilePath))
{
    $profileDir = Split-Path $profilePath -Parent
    vcpkgCreateDirectoryIfNotExists $profileDir
}

Write-Host "`nAdding the following line to ${profilePath}:"
Write-Host "    $profileEntry"

# @() Needed to force Array in PowerShell 2.0
[Array]$existingImports = @(findExistingImportModuleDirectives $profilePath)
if ($existingImports.Count -gt 0)
{
    $existingImportsOut = $existingImports -join "`n    "
    Write-Host "`nposh-vcpkg is already imported to your PowerShell profile. The following entries were found:"
    Write-Host "    $existingImportsOut"
    Write-Host "`nPlease make sure you have started a new Powershell window for the changes to take effect."
    return
}

# Posh-git does the following check, so we should too.
# https://github.com/dahlbyk/posh-git/blob/master/src/Utils.ps1
# If the profile script exists and is signed, then we should not modify it
if (Test-Path $profilePath)
{
    $sig = Get-AuthenticodeSignature $profilePath
    if ($null -ne $sig.SignerCertificate)
    {
        Write-Warning "Skipping add of posh-vcpkg import to profile; '$profilePath' appears to be signed."
        Write-Warning "Please manually add the line '$profileEntry' to your profile and resign it."
        return
    }
}

Add-Content $profilePath -Value "`n$profileEntry" -Encoding UTF8
Write-Host "`nSuccessfully added posh-vcpkg to your PowerShell profile. Please start a new Powershell window for the changes to take effect."
