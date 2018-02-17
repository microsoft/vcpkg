[CmdletBinding()]
param(
    [string]$Triplet
)

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

function findDeployedVersion([string]$vsInstallPath)
{
    if ([string]::IsNullOrEmpty($vsInstallPath))
    {
        return ""
    }

    if (!(Test-Path $vsInstallPath))
    {
        Write-error "Could not find: $vsInstallPath"
        throw 0
    }

    $deploymentRoot = "$vsInstallPath\VC\Tools\MSVC"
    $deployedVersionFile = "$deploymentRoot\$DEPLOYED_VERSION_FILENAME"

    if (Test-Path $deployedVersionFile)
    {
        $deployedVersion = Get-Content $deployedVersionFile
        $deployedVersion = "-$deployedVersion"
        return $deployedVersion
    }
    else
    {
        return ""
    }
}

$tripletFilePath = "$vcpkgRootDir\triplets\$Triplet.cmake"
$vsInstallPath = findVSInstallPathFromTriplet $tripletFilePath
$deployedVersion = findDeployedVersion $vsInstallPath

# "-Format s" is for "SortableDateTimePattern". It should be culture agnostic
$timestamp = (Get-Date -Format s).ToString()
$timestamp = $timestamp -replace ":" # Remove colons from the HH:MM:ss format
$outputFilename = "$timestamp-$triplet$deployedVersion.xml"
$outputPathRoot = "\\vcpkg-000\General\Results"
$outputPath = "$outputPathRoot\$outputFilename"
$cixml = "$vcpkgRootDir\TEST-full-ci.xml"

if (Test-Path $cixml)
{
    vcpkgCreateDirectoryIfNotExists $outputPathRoot
    Write-Host "Copying $cixml to $outputPath..."
    Copy-Item $cixml -Destination $outputPath
    Write-Host "Copying $cixml to $outputPath... done."
}
else
{
    Write-Host "$cixml not found, skip copying it to $outputPath."
}
