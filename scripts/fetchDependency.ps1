[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$dependency
)

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"

Write-Verbose "Fetching dependency: $dependency"
$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

$downloadsDir = "$vcpkgRootDir\downloads"

function fetchDependencyInternal([Parameter(Mandatory=$true)][string]$dependency)
{
    $dependency = $dependency.toLower()

    [xml]$asXml = Get-Content "$scriptsDir\vcpkgDependencies.xml"
    $dependencyData = $asXml.SelectSingleNode("//dependencies/dependency[@name=`"$dependency`"]") # Case-sensitive!

    if ($dependencyData -eq $null)
    {
        throw "Unkown dependency $dependency"
    }

    $requiredVersion = $dependencyData.requiredVersion
    $downloadVersion = $dependencyData.downloadVersion
    $url = $dependencyData.x86url
    $downloadRelativePath = $dependencyData.downloadRelativePath
    $downloadPath = "$downloadsDir\$downloadRelativePath"
    $expectedDownloadedFileHash = $dependencyData.sha256
    $extension = $dependencyData.extension

    if (!(Test-Path $downloadPath))
    {
        Write-Host "Downloading $dependency..."
        vcpkgDownloadFile $url $downloadPath
        Write-Host "Downloading $dependency has completed successfully."
    }

    $downloadedFileHash = vcpkgGetSHA256 $downloadPath
    vcpkgCheckEqualFileHash -filePath $downloadPath -expectedHash $expectedDownloadedFileHash -actualHash $downloadedFileHash


    if ($extension -eq "exe")
    {
        $executableFromDownload = $downloadPath
    }
    elseif ($extension -eq "zip")
    {
        $postExtractionExecutableRelativePath = $dependencyData.postExtractionExecutableRelativePath
        $executableFromDownload = "$downloadsDir\$postExtractionExecutableRelativePath"
        if (-not (Test-Path $executableFromDownload))
        {
            $outFilename = (Get-ChildItem $downloadPath).BaseName
            Write-Host "Extracting $dependency..."
            vcpkgExtractFile -File $downloadPath -DestinationDir $downloadsDir -outFilename $outFilename
            Write-Host "Extracting $dependency has completed successfully."
        }
    }
    else
    {
        throw "Unexpected file type"
    }

    if (-not (Test-Path $executableFromDownload))
    {
        throw ("Could not detect or download " + $dependency)
    }

    return $executableFromDownload
}

$path = fetchDependencyInternal $dependency
Write-Verbose "Fetching dependency: $dependency. Done."
return "<sol>::$path::<eol>"
