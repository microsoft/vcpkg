## First time machine setup:
* [ ] Install Azure PowerShell: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps

## Each Patch Tuesday:
* [ ] Check for depends:vm-update PRs and make relevant changes if possible.
* [ ] Check for Service 360 alerts about vulnerable software we are installing in the VMs and
      update that. (Most often PowerShell needs to be updated to the current 7.2.x release)
* [ ] Run android/create-image.ps1
* [ ] Run linux/create-image.ps1
* [ ] Run windows/create-image.ps1
* [ ] Run android/create-vmss.ps1
* [ ] Run linux/create-vmss.ps1
* [ ] Run windows/create-vmss.ps1
* [ ] Create new pools for all 3 of these in Azure DevOps: https://dev.azure.com/vcpkg/public/_settings/agentqueues
    * Android: 4 agents
    * Linux: 4 agents
    * Windows: 22 agents
* [ ] Update azure-pipelines.yml to point to the new pools.
* [ ] Submit PR with those changes.
* [ ] Submit a full CI rebuild with those changes: https://dev.azure.com/vcpkg/public/_build?definitionId=29  
      refs/pull/NUMBER/head
* [ ] Run `generate-sas-tokens.ps1` and update the relevant libraries on dev.azure.com/vcpkg and
      devdiv.visualstudio.com.
