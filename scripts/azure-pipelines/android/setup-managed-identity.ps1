# Create a system managed identity
# Adding to existing Scale set
$scaleSetResourceGroup = "PrAnd-2023-04-17"
$scaleSetName = "PrAnd-2023-04-17Vmss"

$vm = Get-AzVMss -ResourceGroupName $scaleSetResourceGroup -Name $scaleSetName
Update-AzVMss -ResourceGroupName $scaleSetResourceGroup -VMScaleSetName $scaleSetName -IdentityType SystemAssigned

$spID = $vm.Identity.PrincipalId

$acrGroup = "And-Registry"
$acrName = "AndContainerRegistry"

$resourceID = (Get-AzContainerRegistry -ResourceGroupName $acrGroup -Name $acrName).Id

# needs admin privileges
New-AzRoleAssignment -ObjectId $spID -Scope $resourceID -RoleDefinitionName AcrPull