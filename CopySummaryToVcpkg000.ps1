[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$triplet,
    [Parameter(Mandatory=$true)][string]$buildId
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
        $deployedVersion = "_$deployedVersion"
        return $deployedVersion
    }
    else
    {
        return ""
    }
}

$tripletFilePath = "$vcpkgRootDir\triplets\$triplet.cmake"
$vsInstallPath = findVSInstallPathFromTriplet $tripletFilePath
$deployedVersion = findDeployedVersion $vsInstallPath

# "-Format s" is for "SortableDateTimePattern". It should be culture agnostic
$timestamp = (Get-Date -Format s).ToString()
$timestamp = $timestamp -replace ":" # Remove colons from the HH:MM:ss format
$outputFilename = "$buildId_$timestamp_$triplet$deployedVersion.xml"
$outputPathRoot = "\\vcpkg-000\General\Results"
$outputPath = "$outputPathRoot\$outputFilename"

$ciXmlPath = "$vcpkgRootDir\test-full-ci.xml"

if (Test-Path $ciXmlPath)
{
    vcpkgCreateDirectoryIfNotExists $outputPathRoot
    Write-Host "Copying $ciXmlPath to $outputPath..."
    Copy-Item $ciXmlPath -Destination $outputPath
    Write-Host "Copying $ciXmlPath to $outputPath... done."
}
else
{
    Write-Host "$ciXmlPath not found, skip copying it to $outputPath."
}
