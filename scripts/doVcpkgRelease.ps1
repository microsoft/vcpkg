[CmdletBinding()]
param(

)

$version = git show HEAD:toolsrc/VERSION.txt
#Remove the quotes from the string
$version = $version.Substring(1, $version.length - 2)
$versionRegex = '^\d+\.\d+\.\d+$'
if (!($version -match $versionRegex))
{
     throw [System.ArgumentException] ("Expected version in the form d.d.d but was " + $version)
}

Write-Verbose("New version is " + $version)
$gitTagString = "v$version"

# Intentionally doesn't have ^ (=starts with) to match remote tags as well
$matchingTags = git tag | Where-Object {$_ -match "$gitTagString$"}
if ($matchingTags.Length -gt 0)
{
     throw [System.ArgumentException] ("Git tag matches existing tags: " + $matchingTags)
}

$gitHash = git rev-parse HEAD
Write-Verbose("Git hash is " + $gitHash)

$vcpkgPath = (get-item $PSScriptRoot).parent.FullName
$gitStartOfHash = $gitHash.substring(0,6)
$versionWithStartOfHash = "$version-$gitStartOfHash"
$buildPath = "$vcpkgPath\build-$versionWithStartOfHash"
$releasePath = "$vcpkgPath\release-$versionWithStartOfHash"
Write-Verbose("Build Path " + $buildPath)
Write-Verbose("Release Path " + $releasePath)

# 0 is metrics disabled, 1 is metrics enabled
for ($disableMetrics = 0; $disableMetrics -le 1; $disableMetrics++)
{

    if (!(Test-Path $buildPath))
    {
        New-Item -ItemType directory -Path $buildPath -force | Out-Null
    }

    if (!(Test-Path $releasePath))
    {
        New-Item -ItemType directory -Path $releasePath -force | Out-Null
    }

    # Partial checkout for building vcpkg
    $dotGitDir = "$vcpkgPath\.git"
    $workTreeForBuildOnly = "$buildPath"
    $checkoutThisDirForBuildOnly1 = ".\scripts" # Must be relative to the root of the repository
    $checkoutThisDirForBuildOnly2 = ".\toolsrc" # Must be relative to the root of the repository
    Write-Verbose("Creating partial temporary checkout: $buildPath")
    git --git-dir="$dotGitDir" --work-tree="$workTreeForBuildOnly" checkout $gitHash -f -q -- $checkoutThisDirForBuildOnly1
    git --git-dir="$dotGitDir" --work-tree="$workTreeForBuildOnly" checkout $gitHash -f -q -- $checkoutThisDirForBuildOnly2

    & "$buildPath\scripts\bootstrap.ps1" -disableMetrics $disableMetrics

    # Full checkout which will be a zip along with the executables from the previous step
    $workTree = "$releasePath"
    $checkoutThisDir = ".\" # Must be relative to the root of the repository
    Write-Verbose("Creating temporary checkout: $releasePath")
    git --git-dir=$dotGitDir --work-tree=$workTree checkout $gitHash -f -q -- $checkoutThisDir

    Copy-Item $buildPath\vcpkg.exe $releasePath\vcpkg.exe | Out-Null
    Copy-Item $buildPath\scripts\vcpkgmetricsuploader.exe $releasePath\scripts\vcpkgmetricsuploader.exe | Out-Null

    Write-Verbose("Archiving")
    $outputArchive = "$vcpkgPath\vcpkg-$versionWithStartOfHash.zip"
    if ($disableMetrics -ne 0)
    {
        $outputArchive = "$vcpkgPath\vcpkg-$versionWithStartOfHash-external.zip"
    }
    Compress-Archive -Path "$releasePath\*" -CompressionLevel Optimal -DestinationPath $outputArchive -Force | Out-Null

    Write-Verbose("Removing temporary checkouts: $releasePath")
    Remove-Item -recurse $buildPath | Out-Null
    Remove-Item -recurse $releasePath | Out-Null

    Write-Verbose("Redistributable archive is: $outputArchive")
}
git tag $gitTagString