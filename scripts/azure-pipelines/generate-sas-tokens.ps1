
function Get-SasToken {
    Param(
        [Parameter(Mandatory=$true)]
        [int]$KeyNumber,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$StorageAccountName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ContainerName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Permission
    )

    $keys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    $key = $keys[$KeyNumber - 1]
    $ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key.Value
    $start = Get-Date -AsUTC
    $end = $start.AddDays(90)
    $token = New-AzStorageContainerSASToken -Name $ContainerName -Permission $Permission -StartTime $start -ExpiryTime $end -Context $ctx
    return $token.Substring(1)
}

# Asset Cache:
# Read, Create, List
$assetSas = Get-SasToken -KeyNumber 1 -ResourceGroupName vcpkg-asset-cache -StorageAccountName vcpkgassetcacheeastasia -ContainerName cache -Permission rcl

# Binary Cache:
# Read, Create, List, Write
$binarySas = Get-SasToken -KeyNumber 1 -ResourceGroupName vcpkg-binary-cache -StorageAccountName vcpkgbinarycache -ContainerName cache -Permission rclw
$binaryEASas = Get-SasToken -KeyNumber 1 -ResourceGroupName vcpkg-binary-cache -StorageAccountName vcpkgbinarycacheeastasia -ContainerName cache -Permission rclw

$response = "Asset Cache SAS: Update`n" + `
    "https://dev.azure.com/vcpkg/public/_library?itemType=VariableGroups&view=VariableGroupView&variableGroupId=6&path=vcpkg-asset-caching-credentials`n" + `
    "and`n" + `
    "https://devdiv.visualstudio.com/DefaultCollection/DevDiv/_library?itemType=VariableGroups&view=VariableGroupView&variableGroupId=355&path=vcpkg-asset-caching-credentials`n" + `
    "`n" + `
    "token:`n" + `
    "$assetSas`n" + `
    "`n" + `
    "Binary Cache SAS: Update`n" + `
    "https://dev.azure.com/vcpkg/public/_library?itemType=VariableGroups&view=VariableGroupView&variableGroupId=8&path=vcpkg-binary-caching-credentials`n" + `
    "`n" + `
    "sas-bin:`n" + `
    "$binarySas`n" + `
    "sas-bin-ea:`n" + `
    "$binaryEASas`n"

Write-Host $response
