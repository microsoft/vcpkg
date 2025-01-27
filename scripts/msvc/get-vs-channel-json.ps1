param (
    [string]$InputJson = "downloads/vs-bootstrapper.json",
    [string]$OutputManifest = "downloads/vs-manifest.json"
)

$InputJson = [System.IO.Path]::Combine((Get-Location).Path, $InputJson)
$OutputManifest = [System.IO.Path]::Combine((Get-Location).Path, $OutputManifest)
function Test-Manifest-or-Download {
    param (
        [string]$BootstrapperJsonFile
    )
    $basedir = Split-Path -Parent $BootstrapperJsonFile
    $sha256 = Get-SHA256Hash -File $BootstrapperJsonFile
    $basedir = Join-Path -Path $basedir -ChildPath "vs-$sha256"
    if (-not (Test-Path -Path $basedir)) {
        New-Item -ItemType Directory -Path $basedir
    }
    $channelJsonFile = Join-Path -Path $basedir -ChildPath "channel.json"
    $manifestJsonFile = Join-Path -Path $basedir -ChildPath "manifest.json"

    if (-not (Test-Path -Path $manifestJsonFile)) {
        Get-VSManifestFromBootstrapperJson `
            -BootstrapperJsonFile $BootstrapperJsonFile `
            -ChannelJsonFile $channelJsonFile `
            -ManifestJsonFile $manifestJsonFile
    }

    return $manifestJsonFile
}

function Get-VSManifestFromBootstrapperJson {
    param (
        [Parameter(Mandatory=$true)]
        [string]$BootstrapperJsonFile,
        [Parameter(Mandatory=$true)]
        [string]$ChannelJsonFile,
        [Parameter(Mandatory=$true)]
        [string]$ManifestJsonFile
    )
    $bootstrapperJson = Read-Json-from-File -FilePath $BootstrapperJsonFile
    $channelUri = $bootstrapperJson.installChannelUri
    $previewStr = ""
    Invoke-Download -Url $channelUri -OutputPath $ChannelJsonFile
    ## Download Manifest
    $channelJson = Read-Json-from-File -FilePath $ChannelJsonFile
    $channelItemJson = $channelJson.channelItems
    $manifestEntry = $channelItemJson | Where-Object { $_.id -eq "Microsoft.VisualStudio.Manifests.VisualStudio$previewStr" }
    if ($manifestEntry.Count -ne 1) {
        throw "Only one manifest entry is expected"
    }
    $manifestEntry = $manifestEntry[0]
    if ($manifestEntry.payloads.Count -ne 1) {
        throw "Only one payload expected"
    }
    if ($manifestEntry.payloads[0].fileName -ne "VisualStudio$previewStr.vsman") {
        throw "Only one manifest entry is expected"
    }
    Invoke-Download -Url $manifestEntry.payloads[0].url -OutputPath $ManifestJsonFile
}

Test-Manifest-or-Download -BootstrapperJsonFile ${InputJson}