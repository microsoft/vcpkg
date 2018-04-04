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

    $toolPath="$downloadsDir\tools\$tool-$($toolData.requiredVersion)-windows"
    $exePath = "$toolPath\$($toolData.exeRelativePath)"

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
        $downloadPath = "$toolPath\$($toolData.exeRelativePath)"
    }

    [String]$url = $toolData.url
    if (!(Test-Path $downloadPath))
    {
        Write-Host "Downloading $tool..."
        vcpkgDownloadFile $url $downloadPath
        Write-Host "Downloading $tool... done."
    }

    $expectedDownloadedFileHash = $toolData.sha256
    $downloadedFileHash = vcpkgGetSHA256 $downloadPath
    vcpkgCheckEqualFileHash -filePath $downloadPath -expectedHash $expectedDownloadedFileHash -actualHash $downloadedFileHash

    if ($isArchive)
    {
        Write-Host "Extracting $tool..."
        if ($tool -eq "7zip")
        {
            $sevenZipR = fetchToolInternal "7zr"
            $ec = vcpkgInvokeCommand "$sevenZipR" "x `"$downloadPath`" -o`"$toolPath`" -y"
            if ($ec -ne 0)
            {
                Write-Host "Could not extract $downloadPath"
                throw
            }
        }
        else
        {
            $sevenZipExe = fetchToolInternal "7zip"
            vcpkgExtractFile -sevenZipExe "$sevenZipExe" -ArchivePath $downloadPath -DestinationDir $toolPath
        }
        Write-Host "Extracting $tool... done."
    }

    if (-not (Test-Path $exePath))
    {
        Write-Error "Could not detect or download $tool"
        throw
    }

    return $exePath
}

$path = fetchToolInternal $tool
Write-Verbose "Fetching tool: $tool. Done."
return "<sol>::$path::<eol>"
