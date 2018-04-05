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

    $isArchive = vcpkgHasProperty -object $toolData -propertyName "archiveName"
    if ($isArchive)
    {
        $downloadPath = "$downloadsDir\$($toolData.archiveName)"
    }
    else
    {
        $downloadPath = "$toolPath\$($toolData.exeRelativePath)"
    }

    [String]$url = $toolData.url
    if (!(Test-Path $downloadPath))
    {
        Write-Host "Downloading $tool..."

        # aria2 needs 7zip & 7zip920 to extract. So, we need to download those trough powershell
        if ($tool -eq "aria2" -or $tool -eq "7zip" -or $tool -eq "7zip920")
        {
            vcpkgDownloadFile $url $downloadPath
        }
        else
        {
            $aria2exe = fetchToolInternal "aria2"
            vcpkgDownloadFileWithAria2 $aria2exe $url $downloadPath
        }

        Write-Host "Downloading $tool... done."
    }

    $expectedDownloadedFileHash = $toolData.sha256
    $downloadedFileHash = vcpkgGetSHA256 $downloadPath
    vcpkgCheckEqualFileHash -filePath $downloadPath -expectedHash $expectedDownloadedFileHash -actualHash $downloadedFileHash

    if ($isArchive)
    {
        Write-Host "Extracting $tool..."
        if ($tool -eq "7zip920")
        {
            vcpkgExtractZipFileWithShell -ArchivePath $downloadPath -DestinationDir $toolPath
        }
        elseif ($tool -eq "7zip")
        {
            $sevenZip920 = fetchToolInternal "7zip920"
            $ec = vcpkgInvokeCommand "$sevenZip920" "x `"$downloadPath`" -o`"$toolPath`" -y"
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
