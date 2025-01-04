# Create Docker image for Android

$Date = (Get-Date -Format 'yyyy-MM-dd')
$ResourceGroupName = "PrAnd-WUS"
$ContainerRegistryName = "vcpkgandroidwus"
$ErrorActionPreference = 'Stop'

$registry = Get-AzContainerRegistry -ResourceGroupName $ResourceGroupName -Name $ContainerRegistryName
Connect-AzContainerRegistry -Name $registry.Name

$imageName = "vcpkg-android"
Push-Location $PSScriptRoot
try {
    docker builder prune -f --filter "until=24h"

    docker build . -t $imageName

    $remote = [string]::Format('{0}.azurecr.io/{1}:{2}', $ContainerRegistryName, $imageName, $Date)
    docker tag $imageName $remote

    docker push $remote

    #removes from local environment
    docker rmi --force $remote $imageName

    # pulls and runs ...
    docker logout
} finally {
    Pop-Location
}

Write-Host "Remote: $remote"
