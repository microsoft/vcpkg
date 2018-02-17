[CmdletBinding()]
param(
    [string]$destinationRoot = "."
)

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$destinationRoot = $destinationRoot -replace "\\$"  # Remove potential trailing backslash

function CreateBuildArchiveFromVCFSInternal
{
    [CmdletBinding()]
    param(
        [string]$destinationRoot,
        [Parameter(Mandatory=$true)][ValidateSet('tfs','msvc')][string]$repo,
        [Parameter(Mandatory=$true)][string]$branch,
        [Parameter(Mandatory=$true)][ValidateSet('ret','chk')][string]$retOrChk,
        [Parameter(ParameterSetName='SetLatest')]
        [switch]$latest,
        [Parameter(ParameterSetName='SetBuildNumber')]
        [string]$buildNumber
    )


    function MyCopyItem
    {
        param(
            [string]$fromPath,
            [string]$toPath
        )

        Write-Host "    Copying $fromPath to $toPath..."
        $toPathPart = "$toPath.part"
        #     $time = Measure-Command {Copy-Item $fromPath $toPathPart -Recurse}
        $time = Measure-Command {& Robocopy.exe $fromPath $toPathPart /E /MT /LOG:"robocopylog.txt"}
        Move-Item -Path $toPathPart -Destination $toPath -ErrorAction Stop
        $formattedTime = vcpkgFormatElapsedTime $time
        Write-Host "    Copying done. Time Taken: $formattedTime seconds"
    }

    if ($repo -eq "tfs")
    {
        $buildRoot = "\\vcfs\Builds\VS\feature_$branch"
    }
    else # msvc
    {
        $buildRoot = "\\vcfs\Builds\VS\msvc\$branch"
    }

    if ($latest)
    {
        $buildNumber = Get-Content "$buildRoot\latest.txt"
    }

    $prefix = "$repo-$branch-$retOrChk"
    $buildId = "$prefix-$buildNumber"
    $sevenZip = "$destinationRoot\$buildId.7z"
    if (Test-Path $sevenZip)
    {
        Write-Host "$buildId is already archived ($sevenZip)"
        return
    }

    $from = "$buildRoot\$buildNumber"
    $to = "$destinationRoot\$buildId"

    $toCompleted = "$to.copycompleted"

    if (!(Test-Path $toCompleted))
    {
        vcpkgRemoveItem $to
        Write-Host "Copying x86$retOrChk"
        MyCopyItem  "$from\binaries.x86$retOrChk\bin\i386" "$to\bin\HostX86\x86"
        MyCopyItem  "$from\binaries.x86$retOrChk\bin\x86_amd64" "$to\bin\HostX86\x64"
        MyCopyItem  "$from\binaries.x86$retOrChk\bin\x86_arm" "$to\bin\HostX86\arm"

        Write-Host "Copying amd64$retOrChk"
        MyCopyItem  "$from\binaries.amd64$retOrChk\bin\amd64" "$to\bin\HostX64\x64"
        MyCopyItem  "$from\binaries.amd64$retOrChk\bin\amd64_x86" "$to\bin\HostX64\x86"
        MyCopyItem  "$from\binaries.amd64$retOrChk\bin\amd64_arm" "$to\bin\HostX64\arm"

        # Only copy files and directories that already exist in the VS installation.
        Write-Host "Copying inc, atlmfc, lib"
        MyCopyItem  "$from\binaries.x86$retOrChk\inc" "$to\include"
        MyCopyItem  "$from\binaries.x86$retOrChk\atlmfc" "$to\atlmfc"
        MyCopyItem  "$from\binaries.x86$retOrChk\lib\i386" "$to\lib\x86"
        MyCopyItem  "$from\binaries.amd64$retOrChk\lib\amd64" "$to\lib\x64"

        Move-Item -Path $to -Destination $toCompleted
    }

    $sevenZipPart = "$sevenZip.part"
    vcpkgRemoveItem $sevenZip # Redundant
    vcpkgRemoveItem $sevenZipPart
    Write-Host "Creating 7z..."

    # a = archive
    # -t7z = type is 7z
    # -mx<N> = Compression mode
    # -mmt = Enable multithreading
    # -y = Yes to everything
    #
    # Compression mode-relevant info:
    # - Uncompressed Size = 6.15GB
    # - mx0: Size=6.15GB, CompressionTime= 55.30s , DecompressionTime=37s
    # - mx1: Size=1.22GB, CompressionTime= 1.40min, DecompressionTime=90s
    # - mx3: Size=1.05GB, CompressionTime= 2.66min, DecompressionTime=76s
    # - mx5: Size= 787MB, CompressionTime= 8.59min, DecompressionTime=64s
    # - mx7: Size= 724MB, CompressionTime=11.26min, DecompressionTime=64s
    # - mx9: Size= 675MB, CompressionTime=13.79min, DecompressionTime=59s
    $time7z = Measure-Command {& $scriptsDir\7za.exe a -t7z $sevenZipPart $toCompleted\* -mx9 -mmt -y}
    Move-Item -Path $sevenZipPart -Destination $sevenZip
    $formattedTime7z = vcpkgFormatElapsedTime $time7z
    Write-Host "Creating 7z... done. Time Taken: $formattedTime7z seconds"

    vcpkgRemoveItem $toCompleted

    $dropsOfThisPrefix = (Get-ChildItem $destinationRoot | Where-object -Property name -match "^$prefix.+\.7z$").fullname
    KeepMostRecentFiles $dropsOfThisPrefix -keepCount 10
}

# Create the following archives
CreateBuildArchiveFromVCFSInternal -destinationRoot $destinationRoot -latest -repo tfs -branch WinC -retOrChk ret
CreateBuildArchiveFromVCFSInternal -destinationRoot $destinationRoot -latest -repo tfs -branch WinC -retOrChk chk
CreateBuildArchiveFromVCFSInternal -destinationRoot $destinationRoot -latest -repo msvc -branch master -retOrChk ret
CreateBuildArchiveFromVCFSInternal -destinationRoot $destinationRoot -latest -repo msvc -branch master -retOrChk chk
