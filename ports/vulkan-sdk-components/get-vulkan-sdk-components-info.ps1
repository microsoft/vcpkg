
function Get-GlslangVersion {
    param(
        [string]$SdkVersion,
        [string]$TempWorkDir
    )

    [string]$_GitDir = Join-Path $TempWorkDir "glslang"
    [string]$_GitUrl = 'https://github.com/KhronosGroup/glslang.git'
    [string]$_GitTag = 'vulkan-sdk-' + $SdkVersion

    # The port glslang releases two version for a revision commit,
    # like fa9c3de released with 14.3.0 and vulkan-sdk-1.3.290.0.
    # The version of glslang is the one which is not the SDK version.
    # `--branch` to set cloned HEAD to the commit which should be referenced by 2 tags
    # `--depth=1` to avoid fetching history
    # `--filter=tree:0` and `--no-checkout` to avoid fetching files
    & git clone $_GitUrl $_GitDir `
        "--branch=$_GitTag" `
        "--depth=1" `
        "--filter=tree:0" "--no-checkout" "-q"
    # Get the tag list
    $_VersionCandidates = & git -C $_GitDir tag -l
    Remove-Item -Recurse -Force -Path $_GitDir

    # Check the tag list
    if ($null -eq $_VersionCandidates) { throw 'No VersionCandidates detected.' }
    if (2 -ne $_VersionCandidates.Length) { throw 'VersionCandidates must 2.' }
    if ($_GitTag -notin $_VersionCandidates) { throw 'VersionCandidates must contain SDK.' }
    [string]$_GlslangVersion = $_VersionCandidates | Where-Object { $_ -notmatch $_GitTag }
    if ([version]$_GlslangVersion -lt [version]'0.0.0') { throw 'Failed to determine version' }

    return $_GlslangVersion
}

function Get-VulkanSdkComponentsInfo {
    param(
        [string]$ScriptDir,
        [string]$TempWorkDir
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Error 'This script requires PowerShell 7 or later.'
    }

    if ('vulkan-sdk-components' -ne (Split-Path -Leaf $ScriptDir)) {
        throw 'This script must be run from `vulkan-sdk-components` directory.'
    }

    [string]$VulkanPortDir = $ScriptDir

    [string]$SdkVersion = Join-Path -Resolve $VulkanPortDir 'vcpkg.json'
    | Get-ChildItem | Get-Content -Raw | ConvertFrom-Json -Depth 5
    | Select-Object -ExpandProperty version

    return @{
        'glslang' = Get-GlslangVersion -SdkVersion:$SdkVersion -TempWorkDir:$TempWorkDir
    }

}

$Param = @{
    ScriptDir   = $PSScriptRoot
    TempWorkDir = (New-Item -ItemType Directory Temp:/$(New-Guid)).FullName
}

Get-VulkanSdkComponentsInfo @Param | Format-Table
