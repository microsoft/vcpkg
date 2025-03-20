# Create Docker images for vcpkg

function Build-Image {
    param(
    [string]$Location,
    [string]$ImageName,
    [string]$ContainerRegistryName,
    [string]$Date
    )

    Push-Location $Location
    try {

        docker build . -t $ImageName

        $remote = [string]::Format('{0}.azurecr.io/{1}:{2}', $ContainerRegistryName, $ImageName, $Date)
        docker tag $ImageName $remote

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

docker builder prune -f --filter "until=24h"
Build-Image -Location "$PSScriptRoot/android" `
    -ImageName "vcpkg-android" `
    -ContainerRegistryName $ContainerRegistryName `
    -Date $Date
Build-Image -Location "$PSScriptRoot/linux" `
    -ImageName "vcpkg-linux" `
    -ContainerRegistryName $ContainerRegistryName `
    -Date $Date

docker logout
