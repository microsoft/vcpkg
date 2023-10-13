## First time machine setup:
* [ ] Install Azure PowerShell: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
* [ ] Run `Connect-AzAccount -Subscription CPP_GITHUB`
* [ ] Install Docker

## Each Patch Tuesday:
* [ ] Check for depends:vm-update PRs and make relevant changes if possible.
* [ ] Check for Service 360 alerts (possibly at https://aka.ms/s360 ?) against the service named
      "C++ VCPKG Validation" about vulnerable software we are installing in the VMs and update that.
      (Most often PowerShell needs to be updated)
* [ ] Check for any other software for the Windows images we wish to update and make the edits to do
      so in `scripts/azure-pipelines/windows`
* [ ] Run android/create-docker-image.ps1
* [ ] Update azure-pipelines.yml to point to the new linux docker image from Azure Container Registry
* [ ] Run windows/create-image.ps1
* [ ] Run windows/create-vmss.ps1
* [ ] Create new pools for these in Azure DevOps: https://dev.azure.com/vcpkg/public/_settings/agentqueues
    * Windows: 22 agents
    * Make sure to check 'Grant access permission to all pipelines'
* [ ] Update azure-pipelines.yml to point to the new pools.
* [ ] Submit PR with those changes.
* [ ] Submit a full CI rebuild with those changes: https://dev.azure.com/vcpkg/public/_build?definitionId=29  
      refs/pull/NUMBER/head
* [ ] Look at that and compare with recent build and resolve anything that's not an existing baseline issue.
* [ ] Merge the PR.
* [ ] Update the managed image for compiler testing and delete unused images.
     * CPP_GITHUB\vcpkg-image-minting\PrWinEA
     * Standard HDD LRS
         * East Asia, 1 Replica
         * West US 2, 1 Replica
         * West US 3, 1 Replica
* [ ] After the last build finishes on the previous pool, delete it in the Azure Devops *Organization* UI and its Resource Group. ( https://dev.azure.com/vcpkg/_settings/agentpools ?)
* [ ] Run `generate-sas-tokens.ps1` and update the relevant libraries on dev.azure.com/vcpkg and
      devdiv.visualstudio.com.
* [ ] Mint a new macOS base box.  (See instructions in `scripts/azure-pipelines/osx/README.md`)
* [ ] Deploy the new base box to all hosts.
