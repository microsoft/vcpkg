
Param(
    [Parameter(Mandatory=$true)]
    [int]$KeyNumber
)

$keyName = "key$KeyNumber"

# Asset Cache:
New-AzStorageAccountKey -ResourceGroupName vcpkg-asset-cache -StorageAccountName vcpkgassetcachewus3 -KeyName $keyName

# Binary Cache:
New-AzStorageAccountKey -ResourceGroupName vcpkg-binary-cache -StorageAccountName vcpkgbinarycachewus3 -KeyName $keyName
