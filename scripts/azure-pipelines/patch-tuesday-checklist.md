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
* [ ] Check for any updates possible to `vcpkg-tools.json`. Note that PowerShell currently uses the
    7.2.x series due to customer reported problems on older Windows with 7.3.x and later.
* [ ] Update the first line of android/Dockerfile with the current 'focal' image according to
    https://hub.docker.com/_/ubuntu
* [ ] Run android/create-docker-image.ps1
* [ ] Update azure-pipelines.yml to point to the new linux docker image from Azure Container Registry
* [ ] Run windows/create-image.ps1
* [ ] Update azure-pipelines.yml to point to the new Android image.
* [ ] Submit PR with those changes and merge it.
* [ ] In the Azure portal, mark the newly created image as the 'latest' one.
* [ ] Mint a new macOS base box.  (See instructions in `scripts/azure-pipelines/osx/README.md`)
* [ ] Deploy the new base box to all hosts.
* [ ] Update the software on the CTI's machine #12 to match.
