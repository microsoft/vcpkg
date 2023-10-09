# Create Docker image for Android

$Location = 'westus3'
$Date = (Get-Date -Format 'yyyy-MM-dd')
$ResourceGroupName = "And-Registry"
$ContainerRegistryName = "AndContainerRegistry"
$ErrorActionPreference = 'Stop'

Get-AzResourceGroup -Name $ResourceGroupName -ErrorVariable error -ErrorAction SilentlyContinue
if ($error) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    New-AzContainerRegistry -ResourceGroupName $ResourceGroupName -Name $ContainerRegistryName -EnableAdminUser -Sku Basic
}

$registry = Get-AzContainerRegistry -ResourceGroupName $ResourceGroupName -Name $ContainerRegistryName
Connect-AzContainerRegistry -Name $registry.Name

$imageName = "vcpkg-android"
Push-Location $PSScriptRoot
try {
    docker build . -t $imageName
    
    $remote = [string]::Format('andcontainerregistry.azurecr.io/{0}:{1}', $imageName, $Date)
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
