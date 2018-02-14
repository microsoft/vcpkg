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

$vsInstallPathRegex = @"
set\(VCPKG_VISUAL_STUDIO_PATH[\s]+"(?<path>[^"]+)
"@
$vsInstallPath = ""
Get-Content $tripletFilePath | ForEach-Object {
    if($_ -match $vsInstallPathRegex){
        $vsInstallPath =  $Matches['path']
        return
    }
}

$deployedVersion = findDeployedVersion $vsInstallPath

# "-Format s" is for "SortableDateTimePattern". It should be culture agnostic
$timestamp = (Get-Date -Format s).ToString()
$outputFilename = "$timestamp-$triplet$deployedVersion.xml"
$outputPathRoot = "\\vcpkg-000\General\Results"
$outputPath = "$outputPathRoot\$outputFilename"
$cixml = "$vcpkgRootDir\TEST-full-ci.xml"

vcpkgCreateDirectoryIfNotExists $outputPathRoot
Write-Host "Copying $cixml to $outputPath..."
Copy-Item $cixml -Destination $outputPath
Write-Host "Copying $cixml to $outputPath... done."