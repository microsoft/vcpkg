[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$triplet,
    [Parameter(Mandatory=$true)][string]$buildId,
    [Parameter(Mandatory=$true)][bool]$recordHeaderList
)

Set-StrictMode -Version Latest

$triplet = $triplet.ToLower()

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
$baseName = "${buildId}_${triplet}${deployedVersion}"

# Copy Summary and logs to vcpkg-000
$outputXmlFilename = "$baseName.xml"
$outputPathRoot = "\\vcpkg-000.redmond.corp.microsoft.com\General\Results"
vcpkgCreateDirectoryIfNotExists $outputPathRoot

$ciXmlPath = "$vcpkgRootDir\test-full-ci.xml"
$outputXmlPath = "$outputPathRoot\$outputXmlFilename"
if (Test-Path $ciXmlPath)
{
    Copy-Item $ciXmlPath -Destination $outputXmlPath
}
else
{
    Write-Host "$ciXmlPath not found, skip copying it to $outputXmlPath."
}

if ($recordHeaderList)
{
    $headersListName = "$baseName-headersList.txt"
    $headersListPath = "$vcpkgRootDir\$headersListName"
    $outputHeadersListPath = "$outputPathRoot\$headersListName"
    cmd /c dir "$vcpkgRootDir\installed\$triplet\include" *.h /s /B > $headersListPath
    Copy-Item $headersListPath -Destination $outputHeadersListPath
}


# Delete all logs
if (Test-Path $vcpkgRootDir/buildtrees)
{
    $logs = Get-ChildItem $vcpkgRootDir/buildtrees/*/* | Where-Object { $_.Extension -eq ".log" }
    $logs | Remove-Item
}

vcpkgRemoveItem "$vcpkgRootDir\installed"
