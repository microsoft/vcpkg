[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$tool
)

Set-StrictMode -Version Latest
$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"

Write-Verbose "Fetching tool: $tool"
$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

$downloadsDir = "$vcpkgRootDir\downloads"
vcpkgCreateDirectoryIfNotExists $downloadsDir

function fetchToolInternal([Parameter(Mandatory=$true)][string]$tool)
{
    $tool = $tool.toLower()

    [xml]$asXml = Get-Content "$scriptsDir\vcpkgTools.xml"
    $toolData = $asXml.SelectSingleNode("//tools/tool[@name=`"$tool`"]") # Case-sensitive!

    if ($toolData -eq $null)
    {
        throw "Unkown tool $tool"
    }

    $exePath = "$downloadsDir\$($toolData.exeRelativePath)"

    if (Test-Path $exePath)
    {
        return $exePath
    }

    $isArchive = vcpkgHasProperty -object $toolData -propertyName "archiveRelativePath"
    if ($isArchive)
    {
        $downloadPath = "$downloadsDir\$($toolData.archiveRelativePath)"
    }
    else
    {
        $downloadPath = "$downloadsDir\$($toolData.exeRelativePath)"
    }

    $url = $toolData.url
    if (!(Test-Path $downloadPath))
    {
        Write-Host "Downloading $tool..."
        vcpkgDownloadFile $url $downloadPath
        Write-Host "Downloading $tool has completed successfully."
    }

    $expectedDownloadedFileHash = $toolData.sha256
    $downloadedFileHash = vcpkgGetSHA256 $downloadPath
    vcpkgCheckEqualFileHash -filePath $downloadPath -expectedHash $expectedDownloadedFileHash -actualHash $downloadedFileHash

    if ($isArchive)
    {
        $outFilename = (Get-ChildItem $downloadPath).BaseName
        Write-Host "Extracting $tool..."
        vcpkgExtractFile -File $downloadPath -DestinationDir $downloadsDir -outFilename $outFilename
        Write-Host "Extracting $tool has completed successfully."
    }

    if (-not (Test-Path $exePath))
    {
        throw ("Could not detect or download " + $tool)
    }

    return $exePath
}

$path = fetchToolInternal $tool
Write-Verbose "Fetching tool: $tool. Done."
return "<sol>::$path::<eol>"
