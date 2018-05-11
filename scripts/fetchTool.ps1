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
$downloadsDir = Resolve-Path $downloadsDir

function fetchToolInternal([Parameter(Mandatory=$true)][string]$tool)
{
    $tool = $tool.toLower()

    [xml]$asXml = Get-Content "$scriptsDir\vcpkgTools.xml"
    $toolData = $asXml.SelectSingleNode("//tools/tool[@name=`"$tool`"]") # Case-sensitive!

    if ($toolData -eq $null)
    {
        throw "Unknown tool $tool"
    }

    $toolPath="$downloadsDir\tools\$tool-$($toolData.version)-windows"
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

        # Download aria2 with .NET. aria2 will be used to download everything else.
        if ($tool -eq "aria2")
        {
            vcpkgDownloadFile $url $downloadPath $toolData.sha512
        }
        else
        {
            $aria2exe = fetchToolInternal "aria2"
            vcpkgDownloadFileWithAria2 $aria2exe $url $downloadPath $toolData.sha512
        }

        Write-Host "Downloading $tool... done."
    }
    else
    {
        vcpkgCheckEqualFileHash -url $url -filePath $downloadPath -expectedHash $toolData.sha512
    }

    if ($isArchive)
    {
        Write-Host "Extracting $tool..."
        # Extract 7zip920 with shell because we need it to extract 7zip
        # Extract aria2 with shell because we need it to download 7zip
        if ($tool -eq "7zip920" -or $tool -eq "aria2")
        {
            vcpkgExtractZipFile -ArchivePath $downloadPath -DestinationDir $toolPath
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
            vcpkgExtractFileWith7z -sevenZipExe "$sevenZipExe" -ArchivePath $downloadPath -DestinationDir $toolPath
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
