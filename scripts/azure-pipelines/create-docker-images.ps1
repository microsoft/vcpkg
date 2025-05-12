# Create Docker images for vcpkg

[CmdletBinding()]
param(
    [switch]$OnlyAndroid,
    [switch]$OnlyLinux
)

if ($OnlyAndroid -and $OnlyLinux) {
    Write-Error "At most one of {-OnlyAndroid, -OnlyLinux} may be set"
    return 1
}

if ($OnlyAndroid) {
    Write-Host "Only building Android"
    $BuildAndroid = $true
    $BuildLinux = $false
} elseif ($OnlyLinux) {
    Write-Host "Only building Linux"
    $BuildAndroid = $false
    $BuildLinux = $true
} else {
    $BuildAndroid = $true
    $BuildLinux = $true
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

docker logout $registry.LoginServer
