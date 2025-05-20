# Create Docker images for vcpkg

[CmdletBinding()]
param(
    [switch]$OnlyAndroid,
    [switch]$OnlyLinux,
    [switch]$OnlyArm64Linux
)

if (($OnlyAndroid + $OnlyLinux + $OnlyArm64Linux) -gt 1) {
    Write-Error "At most one of {-OnlyAndroid, -OnlyLinux, -OnlyArm64Linux} may be set"
    return 1
}

if ($OnlyAndroid) {
    Write-Host "Only building Android"
    $BuildAndroid = $true
    $BuildLinux = $false
    $BuildArm64Linux = $false
} elseif ($OnlyLinux) {
    Write-Host "Only building Linux"
    $BuildAndroid = $false
    $BuildLinux = $true
    $BuildArm64Linux = $false
} elseif ($OnlyArm64Linux) {
    Write-Host "Only building Arm64 Linux"
    $BuildAndroid = $false
    $BuildLinux = $false
    $BuildArm64Linux = $true
} else {
    $BuildAndroid = $true
    $BuildLinux = $true
    $BuildArm64Linux = $true
}

function Build-Image {
    param(
        $AcrRegistry,
        [string]$Location,
        [string]$ImageName,
        [string]$Date
    )

    Push-Location $Location
    try {
        docker build . -t $ImageName --build-arg BUILD_DATE=$Date
        $remote = [string]::Format('{0}/{1}:{2}', $AcrRegistry.LoginServer, $ImageName, $Date)
        docker image tag $ImageName $remote
        docker push $remote
        Write-Host "Remote: $remote"
    } finally {
        Pop-Location
    }
}

$Date = (Get-Date -Format 'yyyy-MM-dd')
$ResourceGroupName = "PrAnd-WUS"
$ContainerRegistryName = "vcpkgandroidwus"
$ErrorActionPreference = 'Stop'

$registry = Get-AzContainerRegistry -ResourceGroupName $ResourceGroupName -Name $ContainerRegistryName
Connect-AzContainerRegistry -Name $registry.Name

if ($BuildAndroid) {
    Build-Image -AcrRegistry $registry `
        -Location "$PSScriptRoot/android" `
        -ImageName "vcpkg-android" `
        -Date $Date
}

if ($BuildLinux) {
    Build-Image -AcrRegistry $registry `
        -Location "$PSScriptRoot/linux" `
        -ImageName "vcpkg-linux" `
        -Date $Date
}

if ($BuildArm64Linux) {
    Build-Image -AcrRegistry $registry `
        -Location "$PSScriptRoot/linux-arm64" `
        -ImageName "vcpkg-arm64-linux" `
        -Date $Date
}

docker logout $registry.LoginServer